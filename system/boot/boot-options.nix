# This conf file is used to configure boot 
{ config, pkgs, lib, systemSettings, ... }:

{
  # Enable systemd-boot
  boot.loader.systemd-boot.enable = true;
  # Bootspec needed for secureboot
  boot.bootspec.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # bootloader timeout set, also press t repeatedly in the bootmenu to set there
  boot.loader.timeout = 15;
  # use systemd initrd instead of udev
  # boot.initrd.systemd.enable = true;

  # boot.consoleLogLevel = 0; # configure silent boot
  boot.kernelParams = [
    "nohibernate" # disable hibernate, since you can't on zram swap anyways
    # "acpi_enforce_resources=lax" # openrgb
    # "quiet"
    # "udev.log_level=3"
    # "lockdown=integrity"
  ];

  # plymouth theme for splash screen
  boot.plymouth = rec {
    enable = true;
    theme = "breeze";
    # black_hud circle_hud cross_hud square_hud
    # circuit connect cuts_alt seal_2 seal_3
    # theme = "connect";
    # themePackages = with pkgs; [(
    #   adi1090x-plymouth-themes.override {
    #     selected_themes = [ theme ];
    #   }
    # )];
  };
}
