# GNOME Keyring for storing/encrypting sycrets
# apps like vscode stores encrypted data using it
{ pkgs, ... }:

{
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = [ pkgs.libsecret ]; # libsecret API
  security.pam.services.login.enableGnomeKeyring = true; # load gnome-keyring at startup
  programs.seahorse.enable = true; # enable the graphical frontend for managing
}