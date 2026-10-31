#!/usr/bin/env nu

const NIX_APPLY_EXPR = 'pkg:
  let
    installedOutputs =
      if pkg ? meta.outputsToInstall && builtins.isList pkg.meta.outputsToInstall
      then map (out: if pkg ? ${out} then (pkg.${out}.outPath or pkg.${out}) else (pkg.outPath or pkg)) pkg.meta.outputsToInstall
      else [ (pkg.outPath or pkg) ];
  in
    map toString installedOutputs'

# Test whether a given narinfo URL exists in the target binary cache
def check_cache [url: string]: nothing -> bool {
    try {
        (http head -f -e -m 5sec $url).status == 200
    } catch {
        (^curl -sSf -I --max-time 5 $url | complete).exit_code == 0
    }
}

# Resolve cache_name and raw_targets regardless of positional argument order
def resolve_args [arg1?: string, arg2?: string]: nothing -> record<cache_name: string, raw_targets: any> {
    let is_target = { |x|
        ($x | is-not-empty) and (
            ($x | str starts-with "[") or ($x | str starts-with "{") or ($x | path exists)
        )
    }

    match [$arg1 $arg2] {
        [$a $b] if ($b | is-not-empty) => {
            if (do $is_target $a) {
                { cache_name: $b, raw_targets: $a }
            } else {
                { cache_name: $a, raw_targets: $b }
            }
        }
        [$a _] if ($a | is-not-empty) => {
            if (do $is_target $a) {
                { cache_name: ($env.CACHIX_CACHE_NAME? | default "johnrtitor"), raw_targets: $a }
            } else {
                { cache_name: $a, raw_targets: null }
            }
        }
        _ => {
            { cache_name: ($env.CACHIX_CACHE_NAME? | default "johnrtitor"), raw_targets: null }
        }
    }
}

# Deserialise targets from file, json string, or default TOML
def load_targets [raw: any, toml_file: string = ".github/cache-targets.toml"]: nothing -> list<any> {
    let data = if ($raw | is-not-empty) {
        if ($raw | path exists) {
            open $raw
        } else if ($raw | str starts-with "[") or ($raw | str starts-with "{") {
            $raw | from json
        } else {
            error make { msg: $"Cannot load targets from: ($raw)" }
        }
    } else if ($toml_file | path exists) {
        open $toml_file | get targets
    } else {
        []
    }

    if ($data | describe | str starts-with "record") {
        $data.targets? | default [$data]
    } else {
        $data
    }
}

# Map a target specification to a Nix expression reference
def get_target_eval [target: record]: nothing -> record<ref: string, always_build: bool> {
    let group = ($target.group? | default "")
    let hostname = ($target.hostname? | default "")
    let name = ($target.name? | default "")

    match $group {
        "nixos_config_attribute" => { ref: $".#nixosConfigurations.($hostname).config.($name)", always_build: false }
        "nixos_package" => { ref: $".#nixosConfigurations.($hostname).pkgs.($name)", always_build: false }
        "flake_package" if ($name != "" and $name != "all") => { ref: $".#($name)", always_build: false }
        "remote_flake" => { ref: $name, always_build: false }
        _ => { ref: "", always_build: true }
    }
}

# Predicate: determine if a target is missing from caches and must be built
def target_needs_build [
    target: record
    caches: list<record<url: string, label: string>>
]: nothing -> bool {
    let eval_info = (get_target_eval $target)
    let group = ($target.group? | default "")
    let name = ($target.name? | default "")

    if $eval_info.always_build {
        print $"Always building group ($group)"
        return true
    }

    if ($eval_info.ref | is-empty) {
        print $"Unknown target group ($group), adding to build matrix."
        return true
    }

    let eval_res = (^nix eval --no-eval-cache --json $eval_info.ref --apply $NIX_APPLY_EXPR | complete)
    if $eval_res.exit_code != 0 {
        print $"Could not evaluate ($name), adding to build matrix."
        return true
    }

    let out_paths = (try { $eval_res.stdout | from json | uniq } catch { [] })
    if ($out_paths | is-empty) {
        print $"Could not evaluate ($name), adding to build matrix."
        return true
    }

    for out_path in $out_paths {
        if ($out_path | is-empty) { continue }
        let hash = ($out_path | path basename | split row '-' | first)

        # Lazy streaming search: short-circuits on the first cache hit
        let hit = ($caches | where { |c| check_cache $"($c.url)/($hash).narinfo" } | first)
        if ($hit | is-not-empty) {
            print $"Output path ($out_path) \(($hash)\) for target ($name) is already in ($hit.label)."
        } else {
            print $"Target ($name) output ($out_path) \(($hash)\) is missing from all caches."
            return true
        }
    }

    print $"Target ($name): all required outputs are cached, skipping."
    false
}

def main [
    arg1?: string
    arg2?: string
] {
    if ($env.NIX_STORE? == "null") {
        hide-env NIX_STORE
    }

    let resolved = (resolve_args $arg1 $arg2)
    let cache_name = $resolved.cache_name
    let targets = (load_targets $resolved.raw_targets)

    print $"Input targets: ($targets | to json -r)"
    print $"Cache name: ($cache_name)"

    let caches = [
        { url: $"https://($cache_name).cachix.org", label: "your Cachix" }
        { url: "https://cache.nixos.org", label: "upstream NixOS cache" }
        { url: "https://nix-community.cachix.org", label: "nix-community cache" }
        { url: "https://nyx-cache.chaotic.cx", label: "chaotic cache" }
    ]

    # Functional pipeline filtering: replaces mutable list accumulator
    let missing_targets = ($targets | where { |target| target_needs_build $target $caches })
    let compact_targets = ($missing_targets | to json -r)
    print $"Filtered targets: ($compact_targets)"

    if ($env.GITHUB_OUTPUT? | is-not-empty) {
        $"targets=($compact_targets)\nhas_targets=($missing_targets | is-not-empty)\n"
        | save --append --raw $env.GITHUB_OUTPUT
    }
}
