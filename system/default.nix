{ ... }:
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
    # include printing settings
    ./printing.nix
    # include power plan settings
    # ./system/power.nix
    ];
}