{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  animChoice = ./animations-def.nix;
in
{
  imports = [
    animChoice
    ./binds.nix
    ./env.nix
    ./exec-once.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./windowrules.nix
    ./x-compat.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    # Use the nixos system level Hyprland package and system level portalPackage
    package = null;
    portalPackage = null;

    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };

    extraConfig = builtins.readFile ./zoom.lua;
  };

  home.packages = with pkgs; [
    grim
    slurp
    swappy
    ydotool
    hyprshutdown # Graceful shutdown of apps
    hyprpicker
    #hyprland-qtutils # needed for banners and ANR messages
  ];

  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };

}
