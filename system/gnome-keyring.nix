# GNOME Keyring for storing/encrypting sycrets
# apps like vscode stores encrypted data using it
{ pkgs, ... }:

{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # enable the graphical frontend
  environment.systemPackages = with pkgs; [
    libsecret # for libsecret api
    gnome.libgnome-keyring # for gnome-keyring-daemon
    ];
  security.pam.services.gdm.enableGnomeKeyring = true; # load gnome-keyring at startup
}