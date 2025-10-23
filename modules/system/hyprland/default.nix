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
  hyprlandFlake = false;
  hyprlandLTO = false;
  pkgs-hyprland =
    if hyprlandFlake then inputs.hyprland.packages.${pkgs.hostPlatform.system} else pkgs;
in
{
  imports = [
    ./session.nix
    ./programs
    ./services.nix
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    package = (pkgs-hyprland.hyprland);
    portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
  };

  # hyprland portal is already included, gtk is also needed for compatibility
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  ## QT theming ##
  qt = {
    enable = true;
    style = "kvantum";
    platformTheme = "qt5ct";
  };

  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

    NIXOS_OZONE_WL = "1"; # for electron and chromium apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1"; # firefox should always run on wayland

    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui
  };
}
