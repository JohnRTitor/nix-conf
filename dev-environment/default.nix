{ config, lib, pkgs, ... }:
let
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

  environment.systemPackages = lib.optionals (useDevenv) [ pkgs.devenv ];
}