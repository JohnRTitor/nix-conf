{ config, pkgs, pkgs-master, ... }:
{
  boot.kernelParams = [
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html#active-mode
    "amd-pstate=active"
  ];

  # Zenpower is better power reporting module for AMD processors
  boot.extraModulePackages = with config.boot.kernelPackages; [
    (zenpower.overrideAttrs {
      version = "unstable-2025-02-28";

      src = pkgs.fetchFromGitLab {
        owner = "shdwchn10";
        repo = "zenpower3";
        rev = "138fa0637b46a0b0a087f2ba4e9146d2f9ba2475";
        hash = "sha256-kLtkG97Lje+Fd5FoYf+UlSaEyxFaETtXrSjYzFnHkjY=";
      };
    })
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  environment.systemPackages = [ pkgs-master.zenmonitor ];
}
