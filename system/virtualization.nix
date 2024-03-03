# Configure packages and softwares needed for virtualization
{ config, pkgs, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-manager
    # virtualbox
    distrobox
  ];
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown"; # Shutdown VMs on host shutdown
    spiceUSBRedirection.enable = true; # allows VMs to access USB
    qemu.runAsRoot = false;
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];
  };
  users.users.${userSettings.username}.extraGroups = [ "libvirtd" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}