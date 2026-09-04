# OO7 for storing/encrypting secrets
# apps like vscode stores encrypted data using it
# NOTE: OO7 does not enable a ssh agent/GPG agent in NixOS
{ pkgs, ... }:
{
  services.oo7.enable = true;

  # Enable specifc services to unlock using oo7
  security.pam.services.greetd.oo7.enable = true;
  security.pam.services.greetd-password.enableGnomeKeyring = true;

  programs.seahorse.enable = true; # enable the graphical frontend for managing
}
