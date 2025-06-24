{ pkgs, ... }:
let
  pyprlandSettings = {
    pyprland = {
      plugins = ["scratchpads" "magnify"];
    };

    "scratchpads.term" = {
      animation = "fromTop";
      command = "kitty --class kitty-dropterm";
      class = "kitty-dropterm";
      size = "75% 60%";
    };
  };
in {
  xdg.configFile."pypr/pyprland.toml".source = (pkgs.formats.toml { }).generate "pyprland-config.toml" pyprlandSettings;

  home.packages = with pkgs; [
    pyprland
  ];

  systemd.user.services.pyprland = {
    Unit = {
      Description = "Pyprland Daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.pyprland}/bin/pypr --config .config/hypr/pyprland.toml";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
