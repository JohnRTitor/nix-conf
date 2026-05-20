{
  lib,
  pkgs,
  pkgs-master,
  ...
}:
let
  enableUSWM = false;
in
lib.mkMerge [
  {
    # Enable Cosmic-greeter
    services.displayManager.cosmic-greeter.enable = true;
    environment.systemPackages = with pkgs; [
      cosmic-icons
    ];

    # Run XDG autostart, this is needed for a DE-less setup like Hyprland
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  }

  (lib.mkIf enableUSWM {
    # this adds a new UWSM managed Hyprland session
    # that properly starts Hyprland compositor with
    # `graphical-session.target` and necessary services
    # graphical-session.target is managed by hyprland nixos module
    programs.uwsm.enable = true;
    programs.uwsm.package = pkgs.uwsm;
    programs.uwsm.waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/start-hyprland";
      };
    };

  })
]
