{
  config,
  lib,
  pkgs,
  ...
}:
let
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
      command = "kitty --class kitty-dropterm";
      class = "kitty-dropterm";
      size = "75% 60%";
    };
  };
in
{
  xdg.configFile."pypr/pyprland.toml".source =
    (pkgs.formats.toml { }).generate "pyprland-config.toml"
      pyprlandSettings;

  home.packages = with pkgs; [
    pyprland
  ];

  systemd.user.services.pyprland = {
    Unit = {
      Description = "Autostart Pyprland on Hyprland session start";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];

      X-Restart-Triggers = [
        config.xdg.configFile."pypr/pyprland.toml".source
      ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.pyprland}/bin/pypr --config ${config.home.homeDirectory}/.config/pypr/pyprland.toml";
      Restart = "on-failure";
    };
  };
}
