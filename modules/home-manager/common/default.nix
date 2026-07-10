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

    ./terminals/alacritty.nix
    ./terminals/kitty.nix

    ./cli-tools.nix # Useful CLI tools
    ./btop
    ./fastfetch
    ./vesktop.nix
    ./micro.nix

    ./nix-tools.nix

    ./services.nix # services
    ./cosmic-greeter

    ./hyprland

    ./easyeffects
    ./stylix.nix
    ./yazi

    ./virt-manager.nix

    ./nemo-extra.nix
    ./thunar-extra.nix

    ./kvantum.nix

    # Default Nginx server welcome testing page
    # Nginx global config is located in ../dev-environment/nginx.nix
    ./web-server-html
  ];

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # home manager version should match the system version
  # usually not recommended to change this
  home.stateVersion = osConfig.system.stateVersion;
}
