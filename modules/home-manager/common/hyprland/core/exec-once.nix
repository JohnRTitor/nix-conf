{ config, lib, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) args mkLuaInline;
  inherit (config.myOptions.systemSettings) stylixImage;

  inherit (config.myOptions.programsSettings) statusbar;

  # Shared startup commands
  startupCommands = [
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "qs -c overview"
    "hyprland-change-layout init"
  ]
  ++ lib.optionals (statusbar != "noctalia") [
    "killall -q awww;sleep .5 && awww-daemon"
    "killall -q waybar;sleep .5 && waybar"
    "killall -q swaync;sleep .5 && swaync"
    "nm-applet --indicator"

    # Delayed-only restore so Stylix finishes first,
    # then user's wallpaper wins with a single change
    "sh -lc 'sleep 2 && (qs-wallpapers-restore || waypaper --wallpaper ${stylixImage} --backend awww) >/dev/null 2>&1 || true'"
  ];
in
{
  wayland.windowManager.hyprland.settings.on = lib.mkIf (startupCommands != [ ]) (
    lib.mkAfter [
      (args [
        "hyprland.start"
        (mkLuaInline ''
          function()
          ${lib.concatMapStringsSep "\n" (
            command: "  hl.exec_cmd(${builtins.toJSON command})"
          ) startupCommands}
          end
        '')
      ])
    ]
  );
}
