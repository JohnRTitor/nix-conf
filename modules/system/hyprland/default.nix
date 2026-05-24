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
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;
  };
}
