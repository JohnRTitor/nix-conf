# Configure packages and softwares needed for virtualization
{ config, pkgs, ... }:

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
  boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}