# This config file is used to define system/global packages
# this file is imported ../configuration.nix
# User specific packages should be installed in ./user-packages.nix
# Some packages/apps maybe handled by config options
# They are scattered in ../system/ ../home-manager/ and ../programs/ directories
{
  self,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
      # System Packages
      git # obviously

      ## URL FETCH TOOLS ##
      curl
    ])
    ++ (with pkgs-master; [
      # list of latest packages from nixpkgs master
      # Can be used to install latest version of some packages
    ])
    ++ [
      self.packages.${pkgs.system}.fhs-shell
    ];
  services.flatpak.packages = (import ./flatpak-packages.nix).systemPackages;
}
