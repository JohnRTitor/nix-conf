#!/usr/bin/env nu

const DEFAULT_BUILD_FLAGS = "--print-out-paths --print-build-logs --no-eval-cache"

const NIX_OUTPUTS_EVAL_EXPR = 'pkg:
  let
    toPaths = outs:
      map (out: if pkg ? ${out} then (pkg.${out}.outPath or pkg.${out}) else (pkg.outPath or pkg)) outs;
    fromInstall = if pkg ? meta.outputsToInstall && builtins.isList pkg.meta.outputsToInstall then toPaths pkg.meta.outputsToInstall else [];
    fromOutputs = if pkg ? outputs && builtins.isList pkg.outputs then toPaths pkg.outputs else [];
    direct = [ (pkg.outPath or pkg) ];
  in
    map toString (fromInstall ++ fromOutputs ++ direct)'

def print_warning [msg: string] {
    print $"(ansi yellow_bold)WARNING:(ansi reset) ($msg)"
}

def print_error [msg: string] {
    print -e $"(ansi red_bold)ERROR:(ansi reset) ($msg)"
}

def print_success [msg: string] {
    print $"(ansi green_bold)SUCCESS:(ansi reset) ($msg)"
}

def print_info [msg: string] {
    print $"(ansi cyan_bold)INFO:(ansi reset) ($msg)"
}

def prepare [cache_name: string] {
    touch build.log errors.log success.txt failures.txt
    mkdir logs

    print_info "Starting build preparation"

    if ($cache_name == "") {
        print_error "CACHIX_CACHE_NAME is required"
        exit 1
    }

    if (which cachix | is-empty) {
        print_error "cachix command not found"
        exit 1
    }

    let has_auth = ($env.CACHIX_AUTH_TOKEN? | is-not-empty) or ($env.CACHIX_SIGNING_KEY? | is-not-empty)
    if not $has_auth {
        print_warning "No cachix authentication token or signing key found"
    }
}

# Push store paths to Cachix with logging
def push_to_cachix [paths: list<string>, cache_name: string]: nothing -> bool {
    let push_paths = ($paths | uniq | where { |it| ($it | is-not-empty) and ($it | path exists) })
    if ($push_paths | is-empty) {
        return true
    }

    print_info $"Pushing paths to Cachix \(($cache_name)\):"
    for p in $push_paths {
        print $p
    }
    let paths_str = ($push_paths | str join "\n")
    let push_res = ($paths_str | ^cachix push $cache_name | complete)
    if $push_res.exit_code != 0 {
        print_error $"Failed to push paths to Cachix \(($cache_name)\)"
        return false
    }
    true
}

# Unified build execution runner for both packages and derivations
def execute_nix_build [
    build_ref: string
    build_flags: string
    item_key: string
    display_title: string
    log_file: string
    cache_name: string
    evaluate_extra_outputs: bool
]: nothing -> bool {
    print -n $"* Building ($display_title)..."

    if ("abort" | path exists) {
        print $"(ansi red) ABORTED(ansi reset)"
        return false
    }

    let keepalive_pid = (
        try {
            ^bash -c "while true; do echo -ne '\u{1b}[1;36m BUILDING\u{1b}[0m\n* Building '$1' ('$2')...'; sleep 120; done >&2 & echo $!" -- $display_title $item_key
            | str trim
            | into int
        } catch {
            0
        }
    )

    $"--- Building: ($item_key) ---\nCommand: nix build ($build_ref) ($build_flags)\n" | save --force --raw $log_file

    if ("paths.tmp" | path exists) {
        try { rm -f paths.tmp }
    }

    mut exit_code = 0
    try {
        let status = (try {
            ^bash -c "nix build \"$1\" $2 > paths.tmp 2> >(tee -a \"$3\" >&2)" -- $build_ref $build_flags $log_file
            0
        } catch {
            $env.LAST_EXIT_CODE? | default 1
        })
        $exit_code = $status
    } finally {
        if $keepalive_pid != 0 {
            try { ^pkill -P $keepalive_pid } catch { }
            try { kill $keepalive_pid } catch { }
        }
    }

    if ("paths.tmp" | path exists) {
        let tmp_content = (open --raw paths.tmp)
        if ($tmp_content != "") {
            $tmp_content | save --append --raw $log_file
        }
    }
    $"Exit code: ($exit_code)\n" | save --append --raw $log_file

    if $exit_code == 0 {
        mut all_paths = if ("paths.tmp" | path exists) {
            open --raw paths.tmp | lines | where { is-not-empty }
        } else {
            []
        }

        if $evaluate_extra_outputs {
            let eval_res = (^nix eval --no-eval-cache --json $build_ref --apply $NIX_OUTPUTS_EVAL_EXPR | complete)
            if $eval_res.exit_code == 0 {
                let eval_paths = (try { $eval_res.stdout | from json } catch { [] })
                for p in $eval_paths {
                    if ($p | path exists) {
                        $all_paths = ($all_paths | append $p)
                    }
                }
            }
        }

        let push_paths = ($all_paths | uniq | where { |it| ($it | path exists) })
        if ("paths.tmp" | path exists) {
            try { rm -f paths.tmp }
        }

        let push_ok = (push_to_cachix $push_paths $cache_name)
        if $push_ok {
            print $"(ansi green) SUCCESS(ansi reset)"
            $"($item_key)\n" | save --append --raw success.txt
            return true
        } else {
            print $"(ansi red) FAILED(ansi reset) \(Cachix push failed\)"
            $"($item_key)\t($log_file)\n" | save --append --raw failures.txt
            return false
        }
    } else {
        print $"(ansi red) FAILED(ansi reset) \(Exit code: ($exit_code)\)"
        $"($item_key)\t($log_file)\n" | save --append --raw failures.txt
        return false
    }
}

def build_package [pkg: string, description: string, cache_name: string, build_flags: string]: nothing -> bool {
    let safe_pkg_name = ($pkg | str replace --all --regex '[^a-zA-Z0-9.-]' '_')
    let log_file = $"logs/($safe_pkg_name).log"
    let build_ref = if ($pkg | str contains "#") or ($pkg | str contains ":") or ($pkg | str starts-with ".") or ($pkg | str starts-with "/") {
        $pkg
    } else {
        $".#($pkg)"
    }
    let display_title = $"($description) \(($pkg)\)"

    execute_nix_build $build_ref $build_flags $pkg $display_title $log_file $cache_name true
}

def build_drv [drv: string, name: string, description: string, cache_name: string]: nothing -> bool {
    let safe_name = ($name | str replace --all --regex '[^a-zA-Z0-9.-]' '_')
    let log_file = $"logs/drv_($safe_name).log"
    let build_ref = $"($drv)^*"
    let build_flags = "--print-build-logs --print-out-paths"
    let item_key = $"drv:($name)"
    let display_title = $"($description): ($name)"

    execute_nix_build $build_ref $build_flags $item_key $display_title $log_file $cache_name false
}

def build_target [target: any, cache_name: string, build_flags: string]: nothing -> bool {
    let group = ($target.group? | default "")
    let name = ($target.name? | default "")
    let hostname = ($target.hostname? | default "")
    let user = ($target.user? | default "")

    match $group {
        "flake_package" => {
            if ($name == "" or $name == "all") {
                let eval_res = (^nix eval --no-eval-cache --json .#packages.x86_64-linux --apply 'builtins.attrNames' | complete)
                let pkgs = if $eval_res.exit_code == 0 {
                    try { $eval_res.stdout | from json } catch { [] }
                } else {
                    []
                }

                let all_ok = ($pkgs | all { |p|
                    let ok = (build_package $p "flake package" $cache_name $build_flags)
                    sleep 1sec
                    $ok
                })
                $all_ok
            } else {
                build_package $name "flake package" $cache_name $build_flags
            }
        }
        "nixos_config_attribute" => {
            build_package $"nixosConfigurations.($hostname).config.($name)" $"NixOS config attribute \(($hostname)\)" $cache_name $build_flags
        }
        "nixos_package" => {
            build_package $"nixosConfigurations.($hostname).pkgs.($name)" $"NixOS package \(($hostname)\)" $cache_name $build_flags
        }
        "remote_flake" => {
            build_package $name "Remote flake package" $cache_name $build_flags
        }
        "vscode_extensions" => {
            let vscode_path = $".#nixosConfigurations.($hostname).config.home-manager.users.($user).programs.vscode.profiles.default.extensions"
            let ext_res = (^nix eval --no-eval-cache --json $vscode_path --apply 'map (drv: { pname: (drv.pname or "unknown"), drvPath: (drv.drvPath or "") })' | complete)

            if $ext_res.exit_code != 0 {
                print_warning $"Failed to get VSCode extensions for ($user)@($hostname)"
                return true
            }

            let exts = (try { $ext_res.stdout | from json } catch { [] })
            if ($exts | is-empty) {
                print_warning $"No VSCode extensions found for ($user)@($hostname)"
                return true
            }

            let all_ok = ($exts | all { |ext|
                let drv = ($ext.drvPath? | default "")
                let ext_name = ($ext.pname? | default "unknown")
                if ($drv | is-empty) {
                    true
                } else {
                    let ok = (build_drv $drv $ext_name $"VSCode extension \(($hostname)/($user)\)" $cache_name)
                    sleep 1sec
                    $ok
                }
            })
            $all_ok
        }
        _ => {
            print_error $"Unknown group: ($group)"
            false
        }
    }
}

def generate_report [] {
    let successes = if ("success.txt" | path exists) {
        open --raw success.txt | lines | where { is-not-empty }
    } else {
        []
    }

    let failures = if ("failures.txt" | path exists) {
        open --raw failures.txt
        | lines
        | where { is-not-empty }
        | each { |line|
            let parts = ($line | split row "\t")
            {
                pkg: ($parts | get -o 0 | default $line),
                log: ($parts | get -o 1 | default "")
            }
        }
    } else {
        []
    }

    let success_count = ($successes | length)
    let failure_count = ($failures | length)
    let total_count = ($success_count + $failure_count)

    print ""
    print "================================="
    print "Build Summary"
    print "================================="
    print $"Total builds: ($total_count)"
    print $"Successful: ($success_count)"
    print $"Failed: ($failure_count)"
    print "================================="

    if $failure_count > 0 {
        print ""
        print "Failed builds:"
        for f in $failures {
            print $"  - ($f.pkg) \(Log: ($f.log)\)"
        }
    }

    if ($env.GITHUB_STEP_SUMMARY? | is-not-empty) {
        let failed_section = if $failure_count > 0 {
            let items = ($failures | each { |f|
                let log_content = if ($f.log | is-not-empty) and ($f.log | path exists) {
                    let tail_lines = (open --raw $f.log | lines | last 30 | str join "\n")
                    $"<details><summary>Click to view last 30 lines of error log</summary>\n\n```text\n($tail_lines)\n```\n</details>"
                } else {
                    $"- Log file missing for ($f.pkg)"
                }
                $"#### `($f.pkg)`\n($log_content)\n"
            } | str join "\n")
            $"\n### ❌ Failed Builds\n($items)\n"
        } else {
            ""
        }

        $"\n## 📊 Build Summary\n- **Total builds:** ($total_count)\n- **Successful:** ($success_count)\n- **Failed:** ($failure_count)\n($failed_section)"
        | save --append --raw $env.GITHUB_STEP_SUMMARY
    }
}

# Deserialise targets from file, json string, or default configuration files
def load_targets [arg?: string, toml_file: string = ".github/cache-targets.toml"]: nothing -> list<any> {
    if ($arg | is-not-empty) {
        let data = if ($arg | path exists) {
            open $arg
        } else if ($arg | str starts-with "{") or ($arg | str starts-with "[") {
            $arg | from json
        } else {
            error make { msg: $"Invalid target argument: ($arg)" }
        }

        if ($data | describe | str starts-with "record") {
            $data.targets? | default [$data]
        } else {
            $data
        }
    } else if ($toml_file | path exists) {
        open $toml_file | get targets
    } else if ("cache.json" | path exists) {
        open cache.json | get targets
    } else {
        print_error "No targets file found (.github/cache-targets.toml or cache.json)"
        exit 1
    }
}

def main [target_arg?: string] {
    if ($env.NIX_STORE? == "null") {
        hide-env NIX_STORE
    }

    let cache_name = ($env.CACHIX_CACHE_NAME? | default "johnrtitor")
    prepare $cache_name

    let build_flags = ($env.BUILD_FLAGS? | default $DEFAULT_BUILD_FLAGS)

    let build_failures = try {
        let is_specific = ($target_arg | is-not-empty)
        if $is_specific {
            print_info $"Building specific target: ($target_arg)"
        }

        let targets = (load_targets $target_arg)
        let targets_count = ($targets | length)

        if not $is_specific {
            print_info $"Reading ($targets_count) targets"
        }

        let failures = ($targets | enumerate | reduce --fold 0 { |it, acc|
            if not $is_specific {
                let display_idx = $it.index + 1
                print_info $"Processing target ($display_idx)/($targets_count)..."
            }
            let ok = (build_target $it.item $cache_name $build_flags)
            if not $is_specific {
                sleep 1sec
            }
            if $ok { $acc } else { $acc + 1 }
        })
        $failures
    } catch { |err|
        print_error $"Build execution encountered an error: ($err.rendered? | default ($err.msg? | default $err))"
        1
    }

    generate_report
    print_info "Cleanup completed"

    if $build_failures > 0 {
        print_error $"($build_failures) target\(s\) failed"
        exit 1
    }

    print_success "All targets completed successfully"
}
