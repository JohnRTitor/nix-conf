{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  hypr-plugin-dir = pkgs.symlinkJoin {
    name = "hyrpland-plugins";
    paths = with pkgs.hyprlandPlugins; [
      hyprspace
    ];
  };
in
{
  home.sessionVariables.HYPR_PLUGIN_DIR = hypr-plugin-dir;

  systemd.user.services.load-hyprland-plugin-hyprspace = {
    Unit = {
      Description = "Load Hyprland plugins";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' osConfig.programs.hyprland.package "hyprctl"} plugin load ${hypr-plugin-dir}/lib/libhyprspace.so";
      Restart = "on-failure";
    };
  };
}
