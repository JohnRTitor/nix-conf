{
  pkgs,
  pkgs-master,
  ...
}:
{
  # Enable Cosmic-greeter
  services.displayManager.cosmic-greeter.enable = true;

  # this adds a new UWSM managed Hyprland session
  # that properly starts Hyprland compositor with
  # `graphical-session.target` and necessary services
  programs.uwsm.enable = true;
  programs.uwsm.package = pkgs.uwsm;
  programs.uwsm.waylandCompositors = {
    hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };

  # Run XDG autostart, this is needed for a DE-less setup like Hyprland
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
