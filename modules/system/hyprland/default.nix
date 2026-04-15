# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{
  self,
  config,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  imports = [
    ./session.nix
    ./programs
    ./services.nix
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;
  };

  # hyprland portal is already included, gtk is also needed for compatibility
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
