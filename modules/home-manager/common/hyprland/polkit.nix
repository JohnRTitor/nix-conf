{ lib, pkgs, ... }:

let
  polkit = "lxqt";
in
lib.mkMerge [
  (lib.mkIf (polkit == "pantheon") {
    home.packages = with pkgs; [
      pantheon.pantheon-agent-polkit
    ];
  })

  (lib.mkIf (polkit == "lxqt") {
    systemd.user.services.lxqt-polkit = {
      Unit = {
        Description = "LXQT Polkit Authentication Agent";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
        Restart = "on-failure";
        Slice = "hyprland.slice";
      };
    };
  })
]
