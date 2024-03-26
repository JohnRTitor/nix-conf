# Configure packages and softwares needed for virtualization
{ config, pkgs, userSettings, ... }:

{
  # Enable Virt Manager
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown"; # Shutdown VMs on host shutdown
    qemu.runAsRoot = false;
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];
  };
  
  # Needed for virt-manager to work    
  environment.sessionVariables.GSETTINGS_BACKEND = "keyfile";

  virtualisation.spiceUSBRedirection.enable = true; # allows VMs to access USB
  users.users.${userSettings.username}.extraGroups = [
    "libvirtd" # Needed for Virt Manager
    "vboxusers" # Needed for Virtualbox
  ];

  # Enable Virtualbox
  virtualisation.virtualbox.host.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}