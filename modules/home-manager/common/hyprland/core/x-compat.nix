{ lib, pkgs, ... }:

let
  inherit (import ../utils/lua.nix { inherit lib; }) mkStartupHook;
in
{
  # Essential for preventing legacy X11 applications (like Furmark) from crashing
  # or silently failing when attempting to query X11 libraries for resolution metrics.
  xresources.properties."Xft.dpi" = 96;

  # Instructs XWayland to render windows at integer scaling (1:1) internally.
  # This delegates scaling responsibility to the Wayland compositor, bypassing
  # blurry fractional scaling artifacts in legacy X11 application GUIs.
  wayland.windowManager.hyprland.settings.config.xwayland.force_zero_scaling = true;

  wayland.windowManager.hyprland.settings.on = lib.mkAfter [
    (mkStartupHook [
      # Automatically apply the new Xresources settings
      "xrdb -merge ~/.Xresources"
    ])
  ];

  home.packages = with pkgs; [ xrdb ];
}
