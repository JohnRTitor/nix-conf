# This conf file is used to configure boot 
{ config, pkgs, lib, ... }:

{
  # Bootspec needed for secureboot
  boot.bootspec.enable = true;
  # Use Xanmod Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # zenpower is used for reading temperature, voltage, current and power
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower
  ];

  boot.kernelParams = [ "lockdown=integrity" ];

  boot.kernelPatches = [
    # Kernel lockdown patch
    {
      name = "kernel-lockdown";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        SECURITY_LOCKDOWN_LSM = lib.mkForce yes;
        MODULE_SIG = lib.mkForce yes;
      };
    }
  ];
  # Also load amdgpu-pro at boot
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
  boot.plymouth = rec {
    enable = true;
    # black_hud circle_hud cross_hud square_hud
    # circuit connect cuts_alt seal_2 seal_3
    theme = "connect";
    themePackages = with pkgs; [(
      adi1090x-plymouth-themes.override {
        selected_themes = [ theme ];
      }
    )];
  };

  # start systemd early
  boot.initrd.systemd.enable = true;
}