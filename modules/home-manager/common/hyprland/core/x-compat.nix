{ lib, pkgs, ... }:

let
  inherit (import ../utils/lua.nix { inherit lib; }) mkStartupHook mkEnvList;
in
{
  ## Also see https://wiki.hypr.land/Configuring/Advanced-and-Cool/XWayland/

  # Disables XWayland fractional scaling to prevent blurry legacy X11 GUIs.
  # Windows render at a crisp 1:1 pixel ratio, but UI elements may appear small.
  wayland.windowManager.hyprland.settings.config.xwayland.force_zero_scaling = true;

  # Instead let other toolkits scale windows themselves
  wayland.windowManager.hyprland.settings.env = mkEnvList {
    GDK_SCALE = "1";
    QT_SCALE_FACTOR = "1.2";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR_ROUNDING_POLICY = "PassThrough";
  };

  # ESSENTIAL for preventing legacy X11 applications (like Furmark) from crashing
  # or silently failing when attempting to query X11 libraries for resolution metrics.
  xresources.properties."Xft.dpi" = 96;

  # Optional values, still set however, in case an X11-application needs it
  # Should mirror MODULES/system/fonts.nix
  xresources.properties."Xft.antialias" = 1;
  xresources.properties."Xft.hinting" = 1;
  xresources.properties."Xft.hintstyle" = "hintslight";
  xresources.properties."Xft.rgba" = "rgb";
  xresources.properties."Xft.lcdfilter" = "lcddefault";

  wayland.windowManager.hyprland.settings.on = lib.mkAfter [
    (mkStartupHook [
      # ESSENTIAL to apply the new Xresources settings
      "xrdb -merge ~/.Xresources"
    ])
  ];

  home.packages = with pkgs; [ xrdb ];
}
