{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
{
  # Containers
  # Enable podman and docker compatibility
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    # dockerSocket.enable = true;
  };
  users.users.${userSettings.username}.extraGroups =
    lib.optionals (config.virtualisation.podman.dockerSocket.enable)
      [ "podman" ];
  environment.systemPackages = with pkgs; [ distrobox ];
}
