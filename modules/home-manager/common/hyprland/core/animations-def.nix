{ lib, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkBezier;
in
{
  wayland.windowManager.hyprland.settings = {
    curve = lib.mapAttrsToList mkBezier {
      wind = [
        [
          (-1.00)
          0.9
        ]
        [
          0.1
          1.05
        ]
      ];
      winIn = [
        [
          (-1.00)
          1.1
        ]
        [
          0.1
          1.1
        ]
      ];
      winOut = [
        [
          (-1.00)
          (-0.3)
        ]
        [
          0
          1
        ]
      ];
      liner = [
        [
          0
          1
        ]
        [
          1
          1
        ]
      ];
    };

    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 6;
        bezier = "wind";
        style = "slide";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 6;
        bezier = "winIn";
        style = "slide";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 5;
        bezier = "winOut";
        style = "slide";
      }
      {
        leaf = "windowsMove";
        enabled = true;
        speed = 5;
        bezier = "wind";
        style = "slide";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 1;
        bezier = "liner";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 10;
        bezier = "default";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 5;
        bezier = "wind";
      }
    ];
  };
}
