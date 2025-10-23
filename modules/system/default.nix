{
  lib,
  systemSettings,
  servicesSettings,
  ...
}:
{
  imports = [
    ./nix-settings.nix
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
    ./safe-specialization.nix
    ./shell
    ./programs

    # include global/system packages list and settings
    ../pkgs-configuration/settings.nix
    ../pkgs-configuration/global-packages.nix
    # user packages are imported in ./home.nix

    # include development environment
    ./dev-environment

    # include custom cache server settings (DANGEROUS: this will mess up nix-shell)
    #../misc/custom-cache-server.nix
  ]
  ++
    # Import if Virtualization is enabled
    lib.optionals (servicesSettings.virtualisation) [ ./virtualisation.nix ]
  ++
    # Import if laptop mode is enabled
    lib.optionals (systemSettings.laptop) [ ./power.nix ];

  system.nixos.tags = lib.mkDefault [ "cachyos" ];

  # Dont change this without reading documentation
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # May cause data loss, scary stuff
  system.stateVersion = systemSettings.stableversion; # Did you read the comment?
}
