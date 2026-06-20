{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pantheon.pantheon-agent-polkit
  ];

  # Disabled as it is autostarted by XDG, only this polkit
  # Other polkit providers like polkit-gnome are need to be manually started
  # systemd.user.services.pantheon-agent-polkit = {
  #   Unit = {
  #     Description = "Autostart Pantheon Agent Polkit on Hyprland session start";
  #     After = [ "hyprland-session.target" ];
  #     PartOf = [ "hyprland-session.target" ];
  #     ConditionEnvironment = "WAYLAND_DISPLAY";
  #   };

  #   Install = {
  #     WantedBy = [ "hyprland-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.pantheon.pantheon-agent-polkit}/libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
  #     Restart = "on-failure";
  #     Slice = "hyprland.slice";
  #   };
  # };
}
