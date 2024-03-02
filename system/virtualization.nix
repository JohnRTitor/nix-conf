# Configure packages and softwares needed for virtualization
{ config, pkgs, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [ virt-manager virtualbox distrobox ];
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];
  };
  users.users.${userSettings.username}.extraGroups = [ "libvirtd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}