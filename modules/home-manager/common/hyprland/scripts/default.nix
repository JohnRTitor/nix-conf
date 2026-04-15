{ pkgs, ... }:
{
  home.packages = [
    (import ./hyprland-change-layout.nix { inherit pkgs; })
    (import ./hyprland-float-all.nix { inherit pkgs; })
    (import ./restart-noctalia.nix { inherit pkgs; })

    (import ./screenshotin.nix { inherit pkgs; })
  ];
}
