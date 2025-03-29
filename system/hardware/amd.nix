{ config, pkgs, pkgs-master, ... }:
{
  boot.kernelParams = [
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html#active-mode
    "amd-pstate=active"
  ];

  # Zenpower is better power reporting module for AMD processors
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  environment.systemPackages = [ pkgs-master.zenmonitor ];
}
