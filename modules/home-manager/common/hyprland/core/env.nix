{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkEnvList;
in
{
  wayland.windowManager.hyprland.settings.env = mkEnvList {
    # This is to make electron apps start in wayland
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland, x11";
    CLUTTER_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # Prevent duplicate title bars
    SDL_VIDEODRIVER = "x11";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    # Disabling this by default as it can result in inop cfg
    # Added card2 in case this gets enabled. For better coverage
    # This is mostly needed by Hybrid laptops.
    # but if you have multiple discrete GPUs this will set order
    #"AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1:/dev/card2"
    TERMINAL = "${config.myOptions.programsSettings.terminal}";
    XDG_TERMINAL_EMULATOR = "${config.myOptions.programsSettings.terminal}";
  };
}
