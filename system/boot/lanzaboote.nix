# Configure Lanzaboote (secureboot)
{ pkgs, ... }:
{
  # Bootloader - disable systemd in favor of lanzaboote
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  
  # lanzaboote for secureboot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # enable sbctl - a frontend to create, enroll manage keys
  environment.systemPackages = [ pkgs.sbctl ];
}