# This conf file is used to configure boot 
{ pkgs, ... }:

{
  # bootspec needed for secureboot - MR 22-02
  boot.bootspec.enable = true;
  # Add Xanmod Kernel - MR - 22-02
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # Also load amdgpu at boot
  boot.kernelModules = [ "amdgpu-pro" ];
  # Bootloader - disable systemd in favor of lanzaboote
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  # bootloader timeout set, also press t repeatedly in the bootmenu to set there
  boot.loader.timeout = 15;

  # lanzaboote for secureboot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # plymouth theme for splash screen
  # boot.kernelParams = [ "quiet" ];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.initrd.systemd.enable = true;

}