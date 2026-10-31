#!/usr/bin/env nu

const NIX_APPLY_EXPR = 'pkg:
  let
    installedOutputs =
      if pkg ? meta.outputsToInstall && builtins.isList pkg.meta.outputsToInstall
      then map (out: if pkg ? ${out} then (pkg.${out}.outPath or pkg.${out}) else (pkg.outPath or pkg)) pkg.meta.outputsToInstall
      else [ (pkg.outPath or pkg) ];
  in
    map toString installedOutputs'

def check_cache [url: string]: nothing -> bool {
    let res = (try {
        http head -f -e --max-time 5sec $url
    } catch {
        null
    })
    if $res != null {
        $res.status == 200
    } else {
        let curl_res = (do { ^curl -sSf -I --max-time 5 $url } | complete)
        $curl_res.exit_code == 0
    }
}

def main [
    arg1?: string
    arg2?: string
] {
    let toml_file = ".github/cache-targets.toml"

    # Resolve cache_name and targets input
    let resolved = if ($arg2 != null and $arg2 != "") {
        if ($arg1 | str starts-with "[") or ($arg1 | str starts-with "{") or ($arg1 | path exists) {
            { cache_name: $arg2, raw_targets: $arg1 }
        } else {
            { cache_name: $arg1, raw_targets: $arg2 }
        }
    } else if ($arg1 != null and $arg1 != "") {
        if ($arg1 | str starts-with "[") or ($arg1 | str starts-with "{") or ($arg1 | path exists) {
            { cache_name: ($env.CACHIX_CACHE_NAME? | default "johnrtitor"), raw_targets: $arg1 }
        } else {
            { cache_name: $arg1, raw_targets: null }
        }
    } else {
        { cache_name: ($env.CACHIX_CACHE_NAME? | default "johnrtitor"), raw_targets: null }
    }

    let cache_name = $resolved.cache_name

    let targets = if ($resolved.raw_targets != null) {
        let raw = $resolved.raw_targets
        if ($raw | str starts-with "[") or ($raw | str starts-with "{") {
            let parsed = ($raw | from json)
            if ($parsed | describe | str starts-with "record") {
                if ("targets" in $parsed) {
                    $parsed.targets
                } else {
                    [$parsed]
                }
            } else {
                $parsed
            }
        } else if ($raw | path exists) {
            let loaded = (open $raw)
            if ($loaded | describe | str starts-with "record") and ("targets" in $loaded) {
                $loaded.targets
            } else if ($loaded | describe | str starts-with "record") {
                [$loaded]
            } else {
                $loaded
            }
        } else {
            error make { msg: $"Cannot load targets from: ($raw)" }
        }
    } else if ($toml_file | path exists) {
        open $toml_file | get targets
    } else {
        []
    }

    print $"Input targets: ($targets | to json -r)"
    print $"Cache name: ($cache_name)"

    let cache_labels = {
        $"https://($cache_name).cachix.org": "your Cachix"
        "https://cache.nixos.org": "upstream NixOS cache"
        "https://nix-community.cachix.org": "nix-community cache"
        "https://nyx-cache.chaotic.cx": "chaotic cache"
    }
    let caches = ($cache_labels | columns)


    mut missing_targets = []

    for target in $targets {
        let group = ($target.group? | default "")
        let hostname = ($target.hostname? | default "")
        let name = ($target.name? | default "")
        let user = ($target.user? | default "")

        let target_eval = if $group == "nixos_config_attribute" {
            { ref: $".#nixosConfigurations.($hostname).config.($name)", always_build: false }
        } else if $group == "nixos_package" {
            { ref: $".#nixosConfigurations.($hostname).pkgs.($name)", always_build: false }
        } else if $group == "vscode_extensions" {
            { ref: "", always_build: true }
        } else if $group == "flake_package" {
            if ($name == "" or $name == "all") {
                { ref: "", always_build: true }
            } else {
                { ref: $".#($name)", always_build: false }
            }
        } else if $group == "remote_flake" {
            { ref: $name, always_build: false }
        } else {
            { ref: "", always_build: true }
        }

        let target_ref = $target_eval.ref
        let always_build = $target_eval.always_build

        mut build_it = false

        if $always_build {
            $build_it = true
            print $"Always building group ($group)"
        } else if ($target_ref == "") {
            $build_it = true
            print $"Unknown target group ($group), adding to build matrix."
        } else {
            let eval_res = (do {
                ^nix eval --no-eval-cache --json $target_ref --apply $NIX_APPLY_EXPR
            } | complete)

            if $eval_res.exit_code != 0 {
                $build_it = true
                print $"Could not evaluate ($name), adding to build matrix."
            } else {
                let out_paths = (try {
                    $eval_res.stdout | from json | uniq
                } catch {
                    []
                })

                if ($out_paths | is-empty) {
                    $build_it = true
                    print $"Could not evaluate ($name), adding to build matrix."
                } else {
                    for out_path in $out_paths {
                        if ($out_path | is-empty) { continue }
                        let hash = ($out_path | path basename | split row '-' | first)
                        mut cached = false

                        for cache_url in $caches {
                            let narinfo_url = $"($cache_url)/($hash).narinfo"
                            if (check_cache $narinfo_url) {
                                $cached = true
                                let cache_label = ($cache_labels | get -o $cache_url | default $cache_url)
                                print $"Output path ($out_path) \(($hash)\) for target ($name) is already in ($cache_label)."
                                break
                            }
                        }

                        if not $cached {
                            $build_it = true
                            print $"Target ($name) output ($out_path) \(($hash)\) is missing from all caches."
                            break
                        }
                    }

                    if not $build_it {
                        print $"Target ($name): all required outputs are cached, skipping."
                    }
                }
            }
        }

        if $build_it {
            $missing_targets = ($missing_targets | append $target)
        }
    }

    let compact_targets = ($missing_targets | to json -r)
    print $"Filtered targets: ($compact_targets)"

    if ($env.GITHUB_OUTPUT? != null and $env.GITHUB_OUTPUT != "") {
        let has_targets = if ($missing_targets | length) > 0 { "true" } else { "false" }
        $"targets=($compact_targets)\n" | save --append --raw $env.GITHUB_OUTPUT
        $"has_targets=($has_targets)\n" | save --append --raw $env.GITHUB_OUTPUT
    }
}
