{
  lib,
  systemSettings,
  servicesSettings,
  ...
}:
{
  imports =
    [
      ./nix-settings.nix
      # include boot and kernel settings
      ./boot/kernel.nix
      ./boot/boot-options.nix
      # include user account settings
      ./users.nix
      # include hardware settings
      ./hardware
      # ./hardware/tpm.nix
      # include network settings
      ./network.nix
      # include locale settings
      ./locale.nix
      # include fonts settings
      ./fonts.nix
      # include Hyprland settings
      ./hyprland
      # Include browsers settings
      ./browsers.nix
      # include printing settings
      ./printing.nix
      # include essential services
      ./services
      # include specializations
      ./safe-specialization.nix

      ./shell
    ]
    ++
      # Configure secure boot with lanzaboote, if secureboot is enabled
      lib.optionals (systemSettings.secureboot) [ ./boot/lanzaboote.nix ]
    ++
      # Import if Virtualization is enabled
      lib.optionals (servicesSettings.virtualisation) [ ./virtualisation.nix ]
    ++
      # Import if laptop mode is enabled
      lib.optionals (systemSettings.laptop) [ ./power.nix ];

  system.nixos.tags = lib.mkDefault [ "cachyos" ];
}
