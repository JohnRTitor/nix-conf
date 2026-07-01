{ pkgs, ... }:
{
  home.packages = [
    (import ./screenshotin.nix { inherit pkgs; })
    (import ./rainbow-borders.nix { inherit pkgs; })
  ];
}
