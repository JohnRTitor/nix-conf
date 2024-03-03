# This conf file is used to configure boot 
{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # Bootspec needed for secureboot
  boot.bootspec.enable = true;
  # Use Xanmod Kernel
  boot.kernelPackages = pkgs-unstable.linuxPackages_zen;
  # zenpower is used for reading temperature, voltage, current and power
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower
  ];

  # boot.kernelPatches = [
  #   # Kernel lockdown patch
  #   {
  #     name = "kernel-lockdown";
  #     patch = null;
  #     extraStructuredConfig = with lib.kernel; {
  #       SECURITY_LOCKDOWN_LSM = lib.mkForce yes;
  #       MODULE_SIG = lib.mkForce yes;
  #     };
  #   }
  # ];
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

  # Also load amdgpu at boot
  boot.kernelModules = [ "amdgpu" ];
  # boot.consoleLogLevel = 0; # configure silent boot
  boot.kernelParams = [
    "acpi_enforce_resources=lax" # openrgb
    # "quiet"
    # "udev.log_level=3"
    # "lockdown=integrity"
  ];

  # start systemd early
  boot.initrd.systemd.enable = true;

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
}