{ pkgs, ... }:
{
  imports = [
    ./core
    ./pyprland.nix
    ./quickshell-overview
    ./rofi
    ./scripts

    ./emoji.nix

    # Noctalia and Hyprpanel does not need swaync or wlogout
    ./statusbar/noctalia.nix

    ./statusbar/waybar
    ./wlogout
    ./swaync

    ./statusbar/hyprpanel
  ];

  home.packages = with pkgs; [
    pwvucontrol # audio control
  ];
}
