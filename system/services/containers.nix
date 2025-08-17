{
  config,
  lib,
  pkgs,
  servicesSettings,
  userSettings,
  ...
}:
lib.mkIf servicesSettings.containers {
  # Containers
  # Enable podman and docker compatibility
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
  users.users."masum".extraGroups = lib.optionals (config.virtualisation.podman.dockerSocket.enable) [
    "podman"
  ];
  users.users."masum-work".extraGroups = lib.optionals (config.virtualisation.podman.dockerSocket.enable) [
    "podman"
  ];

  environment.systemPackages =
    with pkgs;
    (
      [ distrobox ]
      ++ lib.optionals (config.virtualisation.podman.enable) [
        podman-desktop
      ]
    );
}
