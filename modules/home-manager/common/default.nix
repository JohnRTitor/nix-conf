{
  config,
  osConfig,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  imports = [
    ./shell # shell (bash, zsh) and starship config
    ./xdg.nix # xdg config
    ./git.nix # git config
    ./alacritty.nix
    ./cli-tools.nix # Useful CLI tools
    ./fastfetch
    # ./thunar.nix
    ./vesktop.nix

    ./nix-tools.nix

    ./services.nix # services
    ./cosmic-greeter
    ./hyprland/pyprland.nix
    ./hyprland/hyprpanel.nix
    ./hyprland/hyprland-plugins.nix

    ./virt-manager.nix

    # Default Nginx server welcome testing page
    # Nginx global config is located in ../dev-environment/nginx.nix
    ./web-server-html
    ./nemo-extra.nix
  ]
  ++ lib.optionals osConfig.programs.thunar.enable [ ./thunar.nix ];

  home.file.".face.icon".source = ./face-logo.png;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # home manager version should match the system version
  # usually not recommended to change this
  home.stateVersion = osConfig.system.stateVersion;
}
