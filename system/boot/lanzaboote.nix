{ pkgs, ... }:
{
  # Bootloader - disable systemd in favor of lanzaboote
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  
  # lanzaboote for secureboot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}