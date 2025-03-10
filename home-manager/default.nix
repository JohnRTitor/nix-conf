{
  config,
  osConfig,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  systemSettings,
  userSettings,
  servicesSettings,
  ...
}:
{
  imports =
    [
      # system packages are imported in ./configuration.nix
      ../pkgs/user-packages.nix # user specific packages
      ./shell # shell (bash, zsh) and starship config
      ./xdg.nix # xdg config
      ./git.nix # git config
      ./alacritty.nix
      ./vscode.nix
      ./cli-tools.nix # Useful CLI tools
      # ./thunar.nix

      ./nix-tools.nix

      ./services.nix # services
    ]
    ++ lib.optionals servicesSettings.nginx [
      # Default Nginx server welcome testing page
      # Nginx global config is located in ../dev-environment/nginx.nix
      ./web-server-html
    ]
    ++ lib.optionals osConfig.programs.thunar.enable [ ./thunar.nix ]
    ++ lib.optionals servicesSettings.virtualisation [ ./virt-manager.nix ];

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # home manager version should match the system version
  # usually not recommended to change this
  home.stateVersion = osConfig.system.stateVersion;
}
