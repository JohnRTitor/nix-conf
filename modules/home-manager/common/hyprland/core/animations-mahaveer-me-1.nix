{ lib, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkBezier;
in
{
  wayland.windowManager.hyprland.settings = {
    curve = lib.mapAttrsToList mkBezier {
      wind = [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.05
        ]
      ];
      winIn = [
        [
          0.1
          1.1
        ]
        [
          0.1
          1.1
        ]
      ];
      winOut = [
        [
          0.3
          (-0.3)
        ]
        [
          0
          1
        ]
      ];
      liner = [
        [
          1
          1
        ]
        [
          1
          1
        ]
      ];
      md3_standard = [
        [
          0.2
          0
        ]
        [
          0
          1
        ]
      ];
      md3_decel = [
        [
          0.05
          0.7
        ]
        [
          0.1
          1
        ]
      ];
      md3_accel = [
        [
          0.3
          0
        ]
        [
          0.8
          0.15
        ]
      ];
      overshot = [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.1
        ]
      ];
      crazyshot = [
        [
          0.1
          1.5
        ]
        [
          0.76
          0.92
        ]
      ];
      hyprnostretch = [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.0
        ]
      ];
      menu_decel = [
        [
          0.1
          1
        ]
        [
          0
          1
        ]
      ];
      menu_accel = [
        [
          0.38
          0.04
        ]
        [
          1
          0.07
        ]
      ];
      easeInOutCirc = [
        [
          0.85
          0
        ]
        [
          0.15
          1
        ]
      ];
      easeOutCirc = [
        [
          0
          0.55
        ]
        [
          0.45
          1
        ]
      ];
      easeOutExpo = [
        [
          0.16
          1
        ]
        [
          0.3
          1
        ]
      ];
      softAcDecel = [
        [
          0.26
          0.26
        ]
        [
          0.15
          1
        ]
      ];
      md2 = [
        [
          0.4
          0
        ]
        [
          0.2
          1
        ]
      ];
    };

    animation = [
      {
        leaf = "border";
        enabled = true;
        speed = 1;
        bezier = "liner";
      }
      {
        leaf = "borderangle";
        enabled = true;
        speed = 30;
        bezier = "liner";
        style = "once";
      }
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
        leaf = "fade";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
      }
      {
        leaf = "layersIn";
        enabled = true;
        speed = 3;
        bezier = "menu_decel";
        style = "slide";
      }
      {
        leaf = "layersOut";
        enabled = true;
        speed = 1.6;
        bezier = "menu_accel";
      }
      {
        leaf = "fadeLayersIn";
        enabled = true;
        speed = 2;
        bezier = "menu_decel";
      }
      {
        leaf = "fadeLayersOut";
        enabled = true;
        speed = 4.5;
        bezier = "menu_accel";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 7;
        bezier = "menu_decel";
        style = "slide";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 5;
        bezier = "wind";
      }
      {
        leaf = "specialWorkspace";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
        style = "slidefadevert 15%";
      }
      {
        leaf = "specialWorkspace";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
        style = "slidevert";
      }
    ];
  };
}
