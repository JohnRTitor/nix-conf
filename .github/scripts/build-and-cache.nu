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

    let has_auth = ($env.CACHIX_AUTH_TOKEN? != null and $env.CACHIX_AUTH_TOKEN != "") or ($env.CACHIX_SIGNING_KEY? != null and $env.CACHIX_SIGNING_KEY != "")
    if not $has_auth {
        print_warning "No cachix authentication token or signing key found"
    }
}

def build_package [pkg: string, description: string, cache_name: string, build_flags: string]: nothing -> bool {
    let safe_pkg_name = ($pkg | str replace --all --regex '[^a-zA-Z0-9.-]' '_')
    let log_file = $"logs/($safe_pkg_name).log"

    print -n $"* Building ($description) \(($pkg)\)..."

    if ("abort" | path exists) {
        print $"(ansi red) ABORTED(ansi reset)"
        return false
    }

    let keepalive_pid = (
        try {
            ^bash -c "while true; do echo -ne '\u{1b}[1;36m BUILDING\u{1b}[0m\n* Building '$1' ('$2')...'; sleep 120; done >&2 & echo $!" -- $description $pkg
            | str trim
            | into int
        } catch {
            0
        }
    )

    let build_ref = if ($pkg | str contains "#") or ($pkg | str contains ":") or ($pkg | str starts-with ".") or ($pkg | str starts-with "/") {
        $pkg
    } else {
        $".#($pkg)"
    }

    $"--- Building: ($pkg) ---\nCommand: nix build ($build_ref) ($build_flags)\n" | save --force --raw $log_file

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
        let eval_res = (do {
            ^nix eval --no-eval-cache --json $build_ref --apply $NIX_OUTPUTS_EVAL_EXPR
        } | complete)

        mut all_paths = if ("paths.tmp" | path exists) {
            open --raw paths.tmp | lines | where { |it| not ($it | is-empty) }
        } else {
            []
        }

        if $eval_res.exit_code == 0 {
            let eval_paths = (try { $eval_res.stdout | from json } catch { [] })
            for p in $eval_paths {
                if ($p | path exists) {
                    $all_paths = ($all_paths | append $p)
                }
            }
        }

        let push_paths = ($all_paths | uniq | where { |it| ($it | path exists) })
        if ("paths.tmp" | path exists) {
            try { rm -f paths.tmp }
        }
        mut push_ok = true
        if not ($push_paths | is-empty) {
            print_info $"Pushing paths to Cachix \(($cache_name)\):"
            for p in $push_paths {
                print $p
            }
            let paths_str = ($push_paths | str join "\n")
            let push_res = (do { $paths_str | ^cachix push $cache_name } | complete)
            if $push_res.exit_code != 0 {
                print_error $"Failed to push paths to Cachix \(($cache_name)\)"
                $push_ok = false
            }
        }

        if $push_ok {
            print $"(ansi green) SUCCESS(ansi reset)"
            $"($pkg)\n" | save --append --raw success.txt
            return true
        } else {
            print $"(ansi red) FAILED(ansi reset) \(Cachix push failed\)"
            $"($pkg)\t($log_file)\n" | save --append --raw failures.txt
            return false
        }
    } else {
        print $"(ansi red) FAILED(ansi reset) \(Exit code: ($exit_code)\)"
        $"($pkg)\t($log_file)\n" | save --append --raw failures.txt
        return false
    }
}

def build_drv [drv: string, name: string, description: string, cache_name: string]: nothing -> bool {
    let safe_name = ($name | str replace --all --regex '[^a-zA-Z0-9.-]' '_')
    let log_file = $"logs/drv_($safe_name).log"

    print -n $"* Building ($description): ($name)..."

    if ("abort" | path exists) {
        print $"(ansi red) ABORTED(ansi reset)"
        return false
    }

    let keepalive_pid = (
        try {
            ^bash -c "while true; do echo -ne '\u{1b}[1;36m BUILDING\u{1b}[0m\n* Building '$1' ('$2')...'; sleep 120; done >&2 & echo $!" -- $description $name
            | str trim
            | into int
        } catch {
            0
        }
    )

    $"--- Building ($description): ($name) ---\nCommand: nix build ($drv)^* --print-build-logs --print-out-paths\n" | save --force --raw $log_file

    if ("paths.tmp" | path exists) {
        try { rm -f paths.tmp }
    }

    mut exit_code = 0
    try {
        let status = (try {
            ^bash -c "nix build \"$1^*\" --print-build-logs --print-out-paths > paths.tmp 2> >(tee -a \"$2\" >&2)" -- $drv $log_file
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
        let push_paths = if ("paths.tmp" | path exists) {
            open --raw paths.tmp | lines | where { |it| not ($it | is-empty) and ($it | path exists) } | uniq
        } else {
            []
        }
        if ("paths.tmp" | path exists) {
            try { rm -f paths.tmp }
        }

        mut push_ok = true
        if not ($push_paths | is-empty) {
            print_info $"Pushing paths to Cachix \(($cache_name)\):"
            for p in $push_paths {
                print $p
            }
            let paths_str = ($push_paths | str join "\n")
            let push_res = (do { $paths_str | ^cachix push $cache_name } | complete)
            if $push_res.exit_code != 0 {
                print_error $"Failed to push paths to Cachix \(($cache_name)\)"
                $push_ok = false
            }
        }

        if $push_ok {
            print $"(ansi green) SUCCESS(ansi reset)"
            $"drv:($name)\n" | save --append --raw success.txt
            return true
        } else {
            print $"(ansi red) FAILED(ansi reset) \(Cachix push failed\)"
            $"drv:($name)\t($log_file)\n" | save --append --raw failures.txt
            return false
        }
    } else {
        print $"(ansi red) FAILED(ansi reset) \(Exit code: ($exit_code)\)"
        $"drv:($name)\t($log_file)\n" | save --append --raw failures.txt
        return false
    }
}

def build_target [target: any, cache_name: string, build_flags: string]: nothing -> bool {
    let group = ($target.group? | default "")
    let name = ($target.name? | default "")
    let hostname = ($target.hostname? | default "")
    let user = ($target.user? | default "")

    if $group == "flake_package" {
        if ($name == "" or $name == "all") {
            let eval_res = (do {
                ^nix eval --no-eval-cache --json .#packages.x86_64-linux --apply 'builtins.attrNames'
            } | complete)
            let pkgs = if $eval_res.exit_code == 0 {
                try { $eval_res.stdout | from json } catch { [] }
            } else {
                []
            }

            mut failed = false
            for p in $pkgs {
                let ok = (build_package $p "flake package" $cache_name $build_flags)
                if not $ok {
                    $failed = true
                }
                sleep 1sec
            }
            return (not $failed)
        } else {
            return (build_package $name "flake package" $cache_name $build_flags)
        }
    } else if $group == "nixos_config_attribute" {
        return (build_package $"nixosConfigurations.($hostname).config.($name)" $"NixOS config attribute \(($hostname)\)" $cache_name $build_flags)
    } else if $group == "nixos_package" {
        return (build_package $"nixosConfigurations.($hostname).pkgs.($name)" $"NixOS package \(($hostname)\)" $cache_name $build_flags)
    } else if $group == "remote_flake" {
        return (build_package $name "Remote flake package" $cache_name $build_flags)
    } else if $group == "vscode_extensions" {
        let vscode_path = $".#nixosConfigurations.($hostname).config.home-manager.users.($user).programs.vscode.profiles.default.extensions"
        let ext_res = (do {
            ^nix eval --no-eval-cache --json $vscode_path --apply 'map (drv: { pname: (drv.pname or "unknown"), drvPath: (drv.drvPath or "") })'
        } | complete)

        if $ext_res.exit_code != 0 {
            print_warning $"Failed to get VSCode extensions for ($user)@($hostname)"
            return true
        }

        let exts = (try { $ext_res.stdout | from json } catch { [] })
        if ($exts | is-empty) {
            print_warning $"No VSCode extensions found for ($user)@($hostname)"
            return true
        }

        mut failed = false
        for ext in $exts {
            let drv = ($ext.drvPath? | default "")
            let ext_name = ($ext.pname? | default "unknown")
            if ($drv | is-empty) { continue }
            let ok = (build_drv $drv $ext_name $"VSCode extension \(($hostname)/($user)\)" $cache_name)
            if not $ok {
                $failed = true
            }
            sleep 1sec
        }
        return (not $failed)
    } else {
        print_error $"Unknown group: ($group)"
        return false
    }
}

def generate_report [] {
    let successes = if ("success.txt" | path exists) {
        open --raw success.txt | lines | where { |it| not ($it | is-empty) }
    } else {
        []
    }

    let failures = if ("failures.txt" | path exists) {
        open --raw failures.txt
        | lines
        | where { |it| not ($it | is-empty) }
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

    if ($env.GITHUB_STEP_SUMMARY? != null and $env.GITHUB_STEP_SUMMARY != "") {
        mut summary = []
        $summary = ($summary | append "")
        $summary = ($summary | append "## 📊 Build Summary")
        $summary = ($summary | append $"- **Total builds:** ($total_count)")
        $summary = ($summary | append $"- **Successful:** ($success_count)")
        $summary = ($summary | append $"- **Failed:** ($failure_count)")

        if $failure_count > 0 {
            $summary = ($summary | append "")
            $summary = ($summary | append "### ❌ Failed Builds")
            for f in $failures {
                $summary = ($summary | append $"#### `($f.pkg)`")
                if ($f.log != "" and ($f.log | path exists)) {
                    $summary = ($summary | append "<details><summary>Click to view last 30 lines of error log</summary>")
                    $summary = ($summary | append "")
                    $summary = ($summary | append "```text")
                    let tail_lines = (open --raw $f.log | lines | last 30 | str join "\n")
                    $summary = ($summary | append $tail_lines)
                    $summary = ($summary | append "```")
                    $summary = ($summary | append "</details>")
                } else {
                    $summary = ($summary | append $"- Log file missing for ($f.pkg)")
                }
                $summary = ($summary | append "")
            }
        }
        ($"($summary | str join "\n")\n") | save --append --raw $env.GITHUB_STEP_SUMMARY
    }
}

def main [target_arg?: string] {
    let cache_name = (if ($env.CACHIX_CACHE_NAME? != null and $env.CACHIX_CACHE_NAME != "") { $env.CACHIX_CACHE_NAME } else { "johnrtitor" })
    prepare $cache_name

    let build_flags = ($env.BUILD_FLAGS? | default $DEFAULT_BUILD_FLAGS)

    let build_failures = try {
        if ($target_arg != null and $target_arg != "") {
            print_info $"Building specific target: ($target_arg)"
            let target_json = if ($target_arg | str starts-with "{") or ($target_arg | str starts-with "[") {
                $target_arg | from json
            } else if ($target_arg | path exists) {
                let loaded = (open $target_arg)
                if ($loaded | describe | str starts-with "record") and ("targets" in $loaded) {
                    $loaded.targets
                } else if ($loaded | describe | str starts-with "record") {
                    [$loaded]
                } else {
                    $loaded
                }
            } else {
                error make { msg: $"Invalid target argument: ($target_arg)" }
            }

            let targets = if ($target_json | describe | str starts-with "record") {
                if ("targets" in $target_json) {
                    $target_json.targets
                } else {
                    [$target_json]
                }
            } else {
                $target_json
            }

            mut failures = 0
            for t in $targets {
                let ok = (build_target $t $cache_name $build_flags)
                if not $ok {
                    $failures = $failures + 1
                }
            }
            $failures
        } else {
            let targets = if (".github/cache-targets.toml" | path exists) {
                open .github/cache-targets.toml | get targets
            } else if ("cache.json" | path exists) {
                open cache.json | get targets
            } else {
                print_error "No targets file found (.github/cache-targets.toml or cache.json)"
                exit 1
            }

            let targets_count = ($targets | length)
            print_info $"Reading ($targets_count) targets"
            mut failures = 0
            mut idx = 1
            for t in $targets {
                print_info $"Processing target ($idx)/($targets_count)..."
                let ok = (build_target $t $cache_name $build_flags)
                if not $ok {
                    $failures = $failures + 1
                }
                $idx = $idx + 1
                sleep 1sec
            }
            $failures
        }
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
