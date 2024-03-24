{ lib, systemSettings, ... }:
{
  imports = [
    # include boot and kernel settings
    ./boot/kernel.nix
    ./boot/boot-options.nix
    # include user account settings
    ./users.nix
    # include hardware settings
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/disk.nix
    ./hardware/graphics.nix
    # include network settings
    ./network.nix
    # include locale settings
    ./locale.nix
    # include fonts settings
    ./fonts.nix
    # include hyprland settings
    ./hyprland.nix
    # Include GNOME Keyring settings
    ./gnome-keyring.nix
    # include printing settings
    ./printing.nix
    # include power plan settings
    # ./system/power.nix
  ]
  ++
  # Configure secure boot with lanzaboote, if secureboot is enabled
  lib.optionals (systemSettings.secureboot) [
    ./boot/lanzaboote.nix
  ]
  ++
  # Import if Virtualization is enabled
  lib.optionals (systemSettings.virtualisation) [
    ./virtualisation.nix
  ]
  ++
  # Import if laptop mode is enabled
  lib.optionals (systemSettings.laptop) [
    ./power.nix
  ];
}