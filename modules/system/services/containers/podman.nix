{
  config,
  lib,
  pkgs,
  servicesSettings,
  userSettings,
  ...
}:
lib.mkIf config.myOptions.servicesSettings.containers {
  # Containers
  # Enable podman and docker compatibility
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  # Allow short image names (e.g. "alpine") used by docker-compose stacks.
  virtualisation.containers.registries.settings = {
    unqualified-search-registries = [ "docker.io" ];
    registry = [
      { location = "docker.io"; }
      { location = "quay.io"; }
    ];
  };
  users.users."masum".extraGroups = lib.optionals (config.virtualisation.podman.dockerSocket.enable) [
    "podman"
  ];
  users.users."masum-work".extraGroups =
    lib.optionals (config.virtualisation.podman.dockerSocket.enable)
      [
        "podman"
      ];

  environment.systemPackages =
    with pkgs;
    (
      [ distrobox ]
      ++ lib.optionals (config.virtualisation.podman.enable) [
        podman-desktop
        podman-compose
      ]
    );
}
