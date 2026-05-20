{ lib, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkBezier;
in
{
  wayland.windowManager.hyprland.settings = {
    # name "moving"
    # credit https://github.com/mylinuxforwork/dotfiles
    curve = lib.mapAttrsToList mkBezier {
      overshot = [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.05
        ]
      ];
      smoothOut = [
        [
          0.5
          0
        ]
        [
          0.99
          0.99
        ]
      ];
      smoothIn = [
        [
          0.5
          (-0.5)
        ]
        [
          0.68
          1.5
        ]
      ];
    };

    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 5;
        bezier = "overshot";
        style = "slide";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 3;
        bezier = "smoothOut";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 3;
        bezier = "smoothOut";
      }
      {
        leaf = "windowsMove";
        enabled = true;
        speed = 4;
        bezier = "smoothIn";
        style = "slide";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 5;
        bezier = "default";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 5;
        bezier = "smoothIn";
      }
      {
        leaf = "fadeDim";
        enabled = true;
        speed = 5;
        bezier = "smoothIn";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 6;
        bezier = "default";
      }
    ];
  };
}
