{ config, pkgs, ... }:
let
  animChoice = ./animations-ml4w-classic.nix;
in
{
  imports = [
    animChoice
    ./binds.nix
    ./env.nix
    ./exec-once.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./windowrules.nix
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      config.wayland.windowManager.hyprland.portalPackage

      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ config.wayland.windowManager.hyprland.package ];
  };
}
