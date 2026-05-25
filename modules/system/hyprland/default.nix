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
let
  mk_desktop_entry =
    opts:
    (pkgs.writeTextFile {
      name = "${opts.name}-manual";
      text = ''
        [Desktop Entry]
        Name=${opts.prettyName} Manual
        Comment=${opts.comment}
        Exec=${opts.binPath} > ~/hyprland.log 2>&1
        Type=Application
      '';
      destination = "/share/wayland-sessions/${opts.name}-manual.desktop";
      derivationArgs = {
        passthru.providedSessions = [ "${opts.name}-manual" ];
      };
    });

  waylandCompositors = {
    hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor";
      binPath = "/run/current-system/sw/bin/start-hyprland";
    };
  };
in
{
  imports = [
    ./session.nix
    ./programs
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager = {
    enable = true;
    sessionPackages = lib.mapAttrsToList (
      name: value:
      mk_desktop_entry {
        inherit name;
        inherit (value)
          prettyName
          comment
          binPath
          extraArgs
          ;
      }
    ) waylandCompositors;
  };

  # XWayland satellite is used instead
  programs.xwayland.enable = false;
}
