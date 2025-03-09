{
  config,
  lib,
  pkgs,
  pkgs-master,
  servicesSettings,
  ...
}: {
  # Configure the build environment

  # Containers and adb should be available by default
  imports =
    [
      # Use devenv instead, it's more flexible
      # and contains a lot of prebuilt packages
      # configured in home manager

      ./jupyter.nix
      # ./deprecated/c-toolchain.nix
      # ./deprecated/php.nix
    ]
    ++ lib.optionals servicesSettings.adb [./adb-toolchain.nix]
    ++ lib.optionals servicesSettings.nginx [
      ./localhost-website.nix
      ./adminer.nix
      ./mysql.nix
    ];

  # Nix LD - allows runnning unpatched FHS binaries without a hitch
  programs.nix-ld.enable = true;

  # Controlled by preferences.nix
  services.nginx.enable = servicesSettings.nginx;
  services.nginx.package = pkgs.nginxQuic;

  # programs.java.enable = true;
}
