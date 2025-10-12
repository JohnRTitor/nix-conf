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
  ]
  ++
    # Import if Virtualization is enabled
    lib.optionals (servicesSettings.virtualisation) [ ./virtualisation.nix ]
  ++
    # Import if laptop mode is enabled
    lib.optionals (systemSettings.laptop) [ ./power.nix ];

  system.nixos.tags = lib.mkDefault [ "cachyos" ];
}
