{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  # Keep consistency with other modules; scriptsDir can supply Weather.py, etc.
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
in
with lib;
{
  # Install any helper scripts from ./scripts into ~/.config/waybar/scripts
  home.file = builtins.listToAttrs (
    map (name: {
      name = ".config/waybar/scripts/" + name;
      value = {
        source = "${scriptsDir}/${name}";
        executable = true;
      };
    }) scripts
  );

  programs.waybar = {

    # Waybar configuration
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        # Layout to mirror waybarpc/config (with requested removals)
        # - Left: start menu, clock, separator, weather
        # - Center: workspaces
        # - Right: tray, pulseaudio, battery, swaync, idle_inhibitor, power
        modules-left = [
          "custom/startmenu"
          "clock"
          "custom/weather"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "battery"
          "tray"
          "custom/notification"
          "idle_inhibitor"
          "pulseaudio"
          "custom/power"
        ];

        # Workspaces (Hyprland)
        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        # 12-hour time format
        clock = {
          format = " {:%I:%M %p}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };

        # Idle inhibitor with coffee mug icon
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = true;
        };

        # Notifications (SwayNotificationCenter via swaync-client)
        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t";
          escape = true;
        };

        # Audio
        pulseaudio = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };

        # Battery
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip = false;
        };

        # Tray
        tray = {
          spacing = 10;
        };

        # Start menu and power menu
        "custom/startmenu" = {
          format = "";
          tooltip = true;
          "tooltip-format" = "App menu";
          # on-click = "rofi -show drun";
          on-click = "launch-nwg-menu";
          "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
        };

        "custom/power" = {
          tooltip = true;
          "tooltip-format" = "Power menu: Left-click for QS logout";
          format = " ⏻ ";
          on-click = "qs-wlogout";
        };

        # Weather widget (uses existing ddubsos Weather.py script if present)
        "custom/weather" = {
          return-type = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
        };
      }
    ];

    # Styling to mirror ~/Projects/waybarpc/style.css (with Catppuccin-like colors)
    style = lib.concatStrings [
      ''
        /* Color variables based on waybarpc/colors.css */
        @define-color bg       #1a1b26;
        @define-color bg-alt   #16161e;
        @define-color bg-alt2  #24283b;
        @define-color bg-alt3  #414868;
        @define-color border   #565f89;
        @define-color border2  #6183bb;
        @define-color text     #c0caf5;
        @define-color text-dark #1a1b26; /* alias for typo tex-dark in original */
        @define-color tex-dark #1a1b26;
        @define-color accent   #7e9cd8;
        @define-color accent2  #957fb8;
        @define-color red      #f7768e;
        @define-color green    #a6e3a1;
        @define-color blue     #89b4fa;

        * {
          font-family: JetBrainsMono Nerd Font, monospace;
          font-size: 13px;
        }

        window#waybar { background-color: @bg; }
        window#waybar.hidden { opacity: 0.5; margin: 15px; }

        /* Workspaces container */
        #workspaces {
          background-color: @bg-alt;
          padding: 2px;
          margin: 2px;
          border-radius: 10px;
        }
        /* 3D shaded workspace buttons */
        #workspaces button {
          all: initial;
          min-width: 0;
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          padding: 6px 12px;
          transition: all 0.1s linear;
          border-top: 1px solid @border;
          box-shadow: 0px 17px 5px 1px rgba(0, 0, 0, 0.2);
          color: @accent2;
          font-weight: 800;
          text-shadow: -1px -1px 1px rgba(205, 214, 244, 0.1), 0px 2px 3px rgba(0, 0, 0, 0.3);
        }
        #workspaces button:first-child {
          border-top-left-radius: 6px;
          border-bottom-left-radius: 6px;
        }
        #workspaces button:last-child {
          border-top-right-radius: 6px;
          border-bottom-right-radius: 6px;
        }
        #workspaces button.empty {
          color: #737373;
          background: transparent;
          text-shadow: none;
          box-shadow: none;
        }
        #workspaces button.active {
          box-shadow: 0px 20px 8px 2px rgba(0, 0, 0, 0.35);
          background: linear-gradient(to bottom, @bg-alt3, @bg-alt);
          color: @text;
          font-size: 25px;
          border-top: 1px solid @border2;
          border-bottom: 3px solid @border2;
          text-shadow: 0px 0px 14px @text;
        }
        #workspaces button.focused {
          background: linear-gradient(to bottom, @accent2, @bg-alt3);
          color: @bg;
          text-shadow: 0px 0px 12px @accent2;
          font-size: 22px;
          border-top: 1px solid @accent2;
        }
        #workspaces button.visible {
          background: linear-gradient(to bottom, @bg-alt3, @bg-alt2);
          color: @accent;
          text-shadow: none;
          font-size: 18px;
          border-top: 1px solid @border;
        }
        #workspaces button.urgent {
          background-color: @red;
          color: @bg;
          text-shadow: 0px 0px 8px @red;
          font-weight: bold;
        }

        /* Clock with gradient block */
        #clock {
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          font-size: 14px;
          margin: 2px;
          padding: 6px 10px;
          border-radius: 6px;
          font-weight: bold;
          border-top: 1px solid @border;
          border-bottom: 2px solid @bg-alt;
          color: @text;
        }

        /* Notifications state color cues */
        #custom-notification.none { color: @green; }
        #custom-notification.notification, #custom-notification.dnd-notification, #custom-notification.inhibited-notification, #custom-notification.dnd-inhibited-notification { color: @red; }

        /* Idle inhibitor colors */
        #idle_inhibitor.activated { color: @green; }
        #idle_inhibitor.deactivated { color: @red; }

        /* Right-side blocks */
        #pulseaudio, #battery, #tray {
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          padding: 4px 8px;
          margin: 2px;
          border-radius: 6px;
          border-top: 1px solid @border;
          border-bottom: 2px solid @bg-alt;
          font-weight: bold;
          color: @text;
        }
        #pulseaudio { margin-left: 0; margin-right: 0; }

        /* Shaded block style (match workspace button look) */
        #custom-startmenu, #custom-weather, #idle_inhibitor, #custom-power, #custom-notification {
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          padding: 6px 10px;
          margin: 2px;
          border-radius: 6px;
          border-top: 1px solid @border;
          border-bottom: 2px solid @bg-alt;
          box-shadow: 0px 12px 4px 1px rgba(0, 0, 0, 0.2);
          text-shadow: -1px -1px 1px rgba(205, 214, 244, 0.1), 0px 2px 3px rgba(0, 0, 0, 0.3);
          color: @text;
          font-size: 14px;
        }
        /* Make icons slightly larger for clarity */
        #custom-startmenu, #idle_inhibitor, #custom-power, #custom-notification { font-size: 16px; }
        #battery.warning, #battery.critical, #battery.urgent { color: @red; }

        /* Separator styling */
        #custom-sep { color: @accent; }

        /* Center the startmenu glyph like the power button */
        #custom-startmenu {
          min-width: 28px;
          min-height: 24px;
          padding-left: 8px;
          padding-right: 12px;
        }
      ''
    ];
  };
}
