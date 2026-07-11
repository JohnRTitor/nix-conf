{ pkgs, ... }:
{
  imports = [
    ./core
    ./polkit.nix
    ./clipboard.nix
    ./pyprland.nix
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
    ## Hyprland Stuff ##
    cliphist # clipboard history
    nwg-look # gtk theme configure
    pamixer
    playerctl # media player control
  ];

  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../../wallpapers;
      recursive = true;
    };

    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };
}
