{ pkgs, ... }:
{
  home.packages = [
    (import ./screenshotin.nix { inherit pkgs; })
  ];
}
