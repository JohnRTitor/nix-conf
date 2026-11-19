{
  config,
  lib,
  pkgs,
  servicesSettings,
  userSettings,
  ...
}:
lib.mkIf config.myOptions.servicesSettings.containers {
  virtualisation.docker = {
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
      # Optionally customize rootless Docker daemon settings.
      # Don't set `data-root`: settings are serialized to a static daemon.json
      # (no ~ / $HOME expansion), and dockerd-rootless already defaults it to
      # "$XDG_DATA_HOME/docker" per user at runtime (~/.local/share/docker).
      daemon.settings = {
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        registry-mirrors = [ "https://mirror.gcr.io" ];
      };
    };
  };

  environment.systemPackages = [ pkgs.docker-compose ];
}
