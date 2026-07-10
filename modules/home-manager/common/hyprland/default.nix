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

    ## Graphical apps ##
    linux-wifi-hotspot # for wifi hotspot
    pwvucontrol # audio control

    ## GNOME Graphical Suite ##
    gnome-text-editor # text editor
    shotcut # video editor
    gnome-system-monitor # system monitor
    loupe # image viewer
    file-roller # archive manager
    evince # document viewer
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
