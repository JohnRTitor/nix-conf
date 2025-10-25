{ lib, pkgs, ... }:
{
  # Hyprpanel is used in place of Waybar
  # programs.waybar = {
  #   enable = true; # enable waybar launcher
  #   package = pkgs.waybar;
  # };
  # systemd.user.services.waybar.environment = {
  #   PATH = lib.mkForce "/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  # };

  programs.hyprlock = {
    enable = true; # enable Hyprlock screen locker
    package = pkgs.hyprlock;
  };

  services.hypridle = {
    enable = true; # enable Hypridle idle manager, needed for Hyprlock
    package = pkgs.hypridle;
  };

  systemd.packages = with pkgs; [
    # swaynotificationcenter
  ];

  # Hyprpanel already runs a notification center, so swaync is not needed
  # systemd.user.services.swaync.wantedBy = [ "graphical-session.target" ];

  security.soteria.enable = true; # Polkit Auth Agent

  ## Configure XDG portal ##
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal
  };
}
