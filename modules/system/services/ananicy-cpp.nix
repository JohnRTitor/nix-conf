{ lib, pkgs, ... }:
{
  # Enable Ananicy CPP for better system performance
  services.ananicy-rs = {
    enable = true;

    rulesProvider = pkgs.ananicy-rules-cachyos.overrideAttrs (prevAttrs: {
      patches = [
        (pkgs.fetchpatch {
          # Revert removal of Compiler rules
          url = "https://github.com/CachyOS/ananicy-rules/commit/5459ed81c0e006547b4f3a3bc40c00d31ad50aa9.patch";
          revert = true;
          hash = "sha256-vc6FDwsAA6p5S6fR1FSdIRC1kCx3wGoeNarG8uEY2xM=";
        })
      ];
    });

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
  };
}
