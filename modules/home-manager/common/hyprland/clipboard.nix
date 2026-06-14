{ config, ... }: {
  services.cliphist = {
    enable = true;
    allowImages = true;

    systemdTargets = [
      config.wayland.systemd.target
      "hyprland-session.target"
    ];
  };
}
