{ pkgs, ... }:
{
  # Enable Ananicy CPP for better system performance
  services.ananicy-rs = {
    enable = true;

    settings = {
      check_freq = 15;

      cgroup_load = true;
      type_load = true;
      rule_load = true;

      apply_nice = true;
      apply_latnice = true;
      apply_ioclass = true;
      apply_ionice = true;
      apply_sched = true;
      apply_oom_score_adj = true;
      apply_cgroup = true;
      apply_cpuset = true;

      cgroup_realtime_workaround = false;
      x3d_mode = "auto";

      loglevel = "info";
      log_applied_rule = false;
    };

    rulesProvider = pkgs.ananicy-rules-cachyos;

    extraTypes = [
      # Define Compiler type with custom nice/ioprio settings
      {
        type = "Compiler";
        nice = 13;
        ioclass = "best-effort";
        ionice = 7;
      }
    ];

    # Written to nixRules.rules, which is loaded *after* 00-default/, so a rule
    # here overrides the shipped one with the same name.
    #
    extraRules = [
      # greetd ships as `type: Launcher` (nice 16, ioclass idle). greetd is the
      # ancestor of the whole graphical session, and nice/ioprio are inherited
      # across fork and preserved across exec, so every session process without a
      # rule of its own ran at nice 16 with idle I/O. Pin the session to the
      # default instead, at the source, so the next login starts clean.
      {
        name = "greetd";
        nice = 0;
        ioclass = "best-effort";
        ionice = 4;
      }
      {
        name = "Hyprland";
        type = "LowLatency_RT";
      }

      # ---- Compiler Rules ----------

      # C, C++ and the versioned names build systems configure with (CC=gcc-15).
      # One pattern instead of six rules; `name` is only the key a match is
      # reported under. The Nix cc/c++ wrappers exec the real clang, so those
      # normalise to `clang` and match either way.
      {
        name = "gcc";
        name_regex = "^(gcc|g\\+\\+|cc|c\\+\\+|clang|clang\\+\\+)(-[0-9.]+)?$";
        type = "Compiler";
      }

      # Build systems
      {
        name = "make";
        type = "Compiler";
      }
      {
        name = "cmake";
        type = "Compiler";
      }
      {
        name = "ninja";
        type = "Compiler";
      }
      {
        name = "meson";
        type = "Compiler";
      }
      {
        name = "bazel";
        type = "Compiler";
      }

      # NixOS: a nix build compiles inside a sandbox whose shell descends
      # from the build driver, so one rule covers a whole build tree.
      # `nix-build` is pure batch, so it can be a Compiler.
      #
      # `nix` itself is deliberately absent, and that is not an oversight. It
      # is the same binary as `nix develop`, which drops you into an
      # interactive shell — so a build tier on `nix` is inherited by your
      # whole dev environment, the greetd problem one level down. It is
      # already BG_CPUIO in upstream cachyos rules (nice 16, SCHED_IDLE), which is aggressive
      # for `nix build` but at least harmless; the trade is builds vs shells
      # and the two cannot be told apart by name. If you want the shell
      # responsive, override `nix` at a middling tier (nice 5) and accept
      # that builds get more aggressive than upstream intends.
      {
        name = "nix-build";
        type = "Compiler";
      }

      # Rust
      {
        name = "cargo";
        type = "Compiler";
      }
      {
        name = "rustc";
        type = "Compiler";
      }

      # Linkers
      {
        name = "ld";
        type = "Compiler";
      }
      {
        name = "ld.bfd";
        type = "Compiler";
      }
      {
        name = "ld.lld";
        type = "Compiler";
      }
      {
        name = "ld.mold";
        type = "Compiler";
      }
      {
        name = "mold";
        type = "Compiler";
      }
      {
        name = "lto1-ltrans";
        type = "Compiler";
      }

      # Go, Java
      {
        name = "go";
        type = "Compiler";
      }
      {
        name = "javac";
        type = "Compiler";
      }

      # `java` is the JVM launcher, so the shipped rule matches every Java
      # program that runs, not just the build — javac above is the one that
      # compiles.
      {
        name = "java";
        nice = 0;
      }

      # If you install a build cache, it belongs here too but as BG_CPU: it
      # is an I/O-heavy background daemon, not a compiler.
      # { name = "sccache"; type = "BG_CPU"; }

      ## ---- Language servers ---- ##

      {
        name = "lsp";
        name_regex = "^(rust-analyzer(-proc-macro-srv)?|clangd|ccls|sourcekit-lsp|gopls|pyright(-langserver)?|pylsp|python-lsp-server|jedi-language-server|tsserver|typescript-language-server|lua-language-server|haskell-language-server(-wrapper)?|hls|zls|taplo|marksman|bash-language-server|[Oo]mni[Ss]harp|docker-language-server|terraform-ls|lemminx|ltex|sqls|(vscode-)?(json|html|css|yaml)-language-server)$";
        type = "BG_CPUIO";
      }

      # `ananicy-rules-cachyos` gives clangd a different tier, so we need to explicitly override here
      {
        name = "clangd";
        type = "BG_CPUIO";
      }

      # lsp-mode bridge in Emacs
      {
        name = "ion.clangd.main";
        type = "BG_CPUIO";
      }
    ];

  };
}
