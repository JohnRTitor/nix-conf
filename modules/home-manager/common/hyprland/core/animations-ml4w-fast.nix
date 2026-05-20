{ lib, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkBezier;
in
{
  wayland.windowManager.hyprland.settings = {
    curve = lib.mapAttrsToList mkBezier {
      linear = [
        [
          0
          0
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
      fluent_decel = [
        [
          0.1
          1
        ]
        [
          0
          1
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
    };

    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
        style = "popin 60%";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 10;
        bezier = "default";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 2.5;
        bezier = "md3_decel";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 3.5;
        bezier = "easeOutExpo";
        style = "slide";
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
