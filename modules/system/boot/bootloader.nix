{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:
lib.mkMerge [
  # Common options
  {
    boot.loader.efi.canTouchEfiVariables = true;
    # bootloader timeout set, also press t repeatedly in the bootmenu to set there
    boot.loader.timeout = 15;
  }

  (lib.mkIf (config.myOptions.systemSettings.bootloader == "limine") {
    boot.loader.limine = {
      # Whether to enable the Limine bootloader.
      enable = true;
      efiSupport = true;
      maxGenerations = 32;
      secureBoot.enable = true;
      style.wallpapers = [ ./City-Rain.png ];
      style.graphicalTerminal.font = {
        scale = "2x2"; # Scale the UI font to make it bigger, default is a lot smaller
      };
    };
  })

  (lib.mkIf (config.myOptions.systemSettings.bootloader == "lanzaboote") {
    # Bootloader - disable systemd in favor of lanzaboote
    boot.loader.systemd-boot.enable = lib.mkForce false;

    # lanzaboote for secureboot
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # sbctl - a frontend to create, enroll manage keys
    # just need once for importing secureboot keys
    # environment.systemPackages = [pkgs.sbctl];
  })

  (lib.mkIf (config.myOptions.systemSettings.bootloader == "systemd-boot") {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
  })
]
