# Configure Lanzaboote (secureboot)
{
  lib,
  pkgs,
  ...
}:
{
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
}
