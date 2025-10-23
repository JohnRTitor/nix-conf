{
  config,
  lib,
  pkgs,
  pkgs-master,
  devSettings,
  ...
}:
{
  # Configure the build environment

  # Containers and adb should be available by default
  imports = [
    ./adb-toolchain.nix
    ./jupyter.nix
    ./example-localhost-website.nix

    ./adminer.nix
    ./mysql.nix
    # Use devenv instead, it's more flexible
    # and contains a lot of prebuilt packages
    # configured in home manager

    # ./deprecated/c-toolchain.nix
    # ./deprecated/php.nix
  ];

  # Nix LD - allows runnning unpatched FHS binaries without a hitch
  programs.nix-ld.enable = true;

  # Controlled by preferences.nix
  services.nginx.enable = config.myOptions.devSettings.nginx;
  services.nginx.package = pkgs.nginxQuic;

  # programs.java.enable = true;
}
