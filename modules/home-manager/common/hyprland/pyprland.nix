{
  config,
  lib,
  pkgs,
  ...
}:
let
  enablePyprland = false;
  inherit (import ../utils/lua.nix { inherit lib; }) mkBind dspExec mkLuaInline;

  pyprlandSettings = {
    pyprland = {
      plugins = [
        "scratchpads"
        "magnify"
        "expose"
      ];
    };

    scratchpads.term = {
      animation = "fromTop";
      command = "systemd-run --user --slice=app.slice --scope kitty --class kitty-dropterm";
      class = "kitty-dropterm";
      size = "75% 70%";
    };
  };
in
# ── Pyprland, a Hyprland plugin ───────────────────────────────────────────────
lib.mkIf enablePyprland {
  wayland.windowManager.hyprland.settings.bind = [
    (mkBind ''mainMod .. " + t"'' "Dropdown Terminal" (dspExec "pypr toggle term") { })
    (mkBind ''mainMod .. " + z"'' "Pyprland Zoom" (dspExec "pypr zoom") { })
  ];

  xdg.configFile."pypr/pyprland.toml".source =
    (pkgs.formats.toml { }).generate "pyprland-config.toml"
      pyprlandSettings;

  home.packages = with pkgs; [
    pyprland
  ];

  systemd.user.services.pyprland = {
    Unit = {
      Description = "Autostart Pyprland on Hyprland session start";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];

      X-Restart-Triggers = [
        config.xdg.configFile."pypr/pyprland.toml".source
      ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.pyprland}/bin/pypr --config ${config.home.homeDirectory}/.config/pypr/pyprland.toml";
      Restart = "on-failure";
      Slice = "hyprland.slice";
    };
  };
}
