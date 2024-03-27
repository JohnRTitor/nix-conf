{ config, lib, pkgs, pkgs-edge, userSettings, ... }:
let
  # To be able to use cachix cache from devenv
  # nix.settings.trusted-users = [ "example-user" ]
  # has to be set
  useDevenv = true;
in
{
  # Configure the build environment

  # Containers and adb should be available by default
  imports = [
    ./containers.nix
    ./adb-toolchain.nix
  ]
  # if dev env is enabled don't install c and php toolchain
  ++ lib.optionals (!useDevenv)
  [
    ./deprecated/c-toolchain.nix
    ./deprecated/php.nix
  ];

  environment.systemPackages = lib.optionals (useDevenv) [ pkgs-edge.devenv ];
  programs.direnv.enable = true; # also enable direnv
}