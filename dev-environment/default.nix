{ pkgs, ... }:
{
  # Configure the build environment
  imports = [
    ./containers.nix
    ./adb-toolchain.nix
    ./c-toolchain.nix
    ./php.nix
  ];
  environment.systemPackages = with pkgs; [ 
    devenv
  ];
}