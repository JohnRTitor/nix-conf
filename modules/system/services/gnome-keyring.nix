# GNOME Keyring for storing/encrypting sycrets
# apps like vscode stores encrypted data using it
# NOTE: GNOME keyring does not enable a ssh agent/GPG agent in NixOS
{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # enable the graphical frontend for managing

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    greetd-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };
}
