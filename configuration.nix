# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, lib, pkgs, pkgs-stable, pkgs-edge, pkgs-vscode-extensions, systemSettings, userSettings, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include system modules
    ./system

    # include global/system packages list
    ./pkgs/global-packages.nix
    # user packages are imported in ./home.nix

    # include APPS settings
    ./programs/openrgb.nix
    #./programs/kde-connect.nix
      
    # include development environment
    ./dev-environment # check ./dev-environment/default.nix for more details

    # include custom cache server settings
    #./misc/custom-cache-server.nix # disabled temporarily cause it messes up nix-shell
  ];

  # Features for building
  nix.settings.system-features = [
    # Defaults
    "big-parallel"
    "benchmark"
    "kvm"
    "nixos-test"
    # Additional
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4"
    "gccarch-znver4"
  ];
  # User should be allowed to use custom cache servers
  nix.settings.trusted-users = [ userSettings.username ];

  networking.hostName = systemSettings.hostname; # Define your hostname in flake.nix

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix command and flakes
  nix.settings.auto-optimise-store = true; # enable deleting duplicate content in store

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = systemSettings.stableversion; # Did you read the comment?
}
