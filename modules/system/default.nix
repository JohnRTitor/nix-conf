{
  config,
  lib,
  servicesSettings,
  ...
}:
{
  imports = [
    ./nix
    ./boot/kernel.nix
    ./boot/bootloader.nix
    ./users.nix
    ./hardware
    ./hardware/tpm.nix
    ./network.nix
    ./locale.nix
    ./fonts.nix
    ./hyprland
    ./browsers.nix
    ./printing.nix
    ./services
    ./shell
    ./programs

    ./stylix.nix

    # include global/system packages list and settings
    ../pkgs-configuration/settings.nix
    ../pkgs-configuration/global-packages.nix
    # user packages are imported in ./home.nix

    # include development environment
    ./dev-environment
    ./power.nix
    ./virtualisation.nix
  ];

  # Dont change this without reading documentation
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # May cause data loss, scary stuff
  system.stateVersion = config.myOptions.systemSettings.stableversion; # Did you read the comment?
}
