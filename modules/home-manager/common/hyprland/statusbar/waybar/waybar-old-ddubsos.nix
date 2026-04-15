{
  pkgs,
  lib,
  ...
}:
let
  # Install helper scripts shipped in modules/home/waybar/scripts into ~/.config/waybar/scripts
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);

  # Updated CAVA visualizer script packaged via Nix (from waybar-jak-catppuccin.nix)
  waybarCava = pkgs.writeShellScriptBin "WaybarCava" ''
    set -euo pipefail

    # Ensure cava exists
    if ! command -v cava >/dev/null 2>&1; then
      echo "cava not found in PATH" >&2
      exit 1
    fi

    # Characters for vertical bars (0..7)
    bar="▁▂▃▄▅▆▇█"

    # Build sed script that maps 0..7 to glyphs and strips ';'
    dict="s/;//g"
    bar_length=''${#bar}
    for ((i = 0; i < bar_length; i++)); do
      dict+=";s/$i/''${bar:$i:1}/g"
    done

    RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
    pidfile="$RUNTIME_DIR/waybar-cava.pid"
    if [ -f "$pidfile" ]; then
      oldpid=$(cat "$pidfile" || true)
      if [ -n "''${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
        kill "$oldpid" 2>/dev/null || true
        sleep 0.1 || true
      fi
    fi
    echo $$ > "$pidfile"

    config_file=$(mktemp "''${RUNTIME_DIR}/waybar-cava.XXXXXX.conf")
    cleanup() {
      rm -f "$config_file" "$pidfile"
    }
    trap cleanup EXIT INT TERM

    cat >"$config_file" <<EOF
    [general]
    framerate = 30
    bars = 10

    [input]
    method = pulse
    source = auto

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 7
    EOF

    exec cava -p "$config_file" | sed -u "$dict"
  '';
in
with lib;
{
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
    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 6;

        # Old ddubsOS layout converted, with updated CAVA and tweaks
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "group/qs_wallpapers"
          "clock"
          "hyprland/window"
          "custom/sep_left"
          "custom/cava_mviz"
          "custom/sep_right"
          "tray"
        ];
        modules-right = [
          "custom/weather"
          "idle_inhibitor"
          "custom/notification"
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "custom/power"
        ];

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
        clock = {
          format = " {:%H:%M}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big><tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 25;
          separate-outputs = false;
        };
        memory = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        cpu = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        disk = {
          format = " {free}";
          tooltip = true;
        };
        network = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
        };
        tray = {
          spacing = 12;
        };
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

        # Updated CAVA visualizer
        "custom/cava_mviz" = {
          exec = "${waybarCava}/bin/WaybarCava";
          format = "{}";
        };

        # Separators
        "custom/sep_left" = {
          format = " [";
          tooltip = false;
        };
        "custom/sep_right" = {
          format = "] ";
          tooltip = false;
        };

        "custom/startmenu" = {
          tooltip = true;
          tooltip-format = "App menu";
          format = "";
          on-click = "rofi-legacy.menu";
          "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
          #on-click = "rofi -show drun";
        };

        # Wallpaper quick-switchers (same color/background as startmenu)
        "custom/qs_wallpapers_apply" = {
          format = "";
          tooltip = true;
          tooltip-format = "Set image wallpaper";
          on-click = "qs-wallpapers-apply";
        };
        "custom/qs_vid_wallpapers_apply" = {
          format = "";
          tooltip = true;
          tooltip-format = "Set video wallpaper";
          on-click = "qs-vid-wallpapers-apply";
        };

        # Group the QS buttons to avoid bar spacing between them
        "group/qs_wallpapers" = {
          orientation = "inherit";
          modules = [
            "custom/qs_wallpapers_apply"
            "custom/qs_vid_wallpapers_apply"
          ];
        };

        # Notifications (compatible with swaync if present)
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
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
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };

        # Idle inhibitor with colored coffee mug icons (green active, red inactive)
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "<span foreground='#00f769'></span>";
            deactivated = "<span foreground='#ea51b2'></span>";
          };
          tooltip = true;
        };

        "custom/weather" = {
          return-type = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
        };

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
          on-click = "";
          tooltip = false;
        };

        # Power menu with qs-wlogout primary and rofi fallback (icon: ⏻)
        "custom/power" = {
          tooltip = true;
          "tooltip-format" = "Power menu: Left-click for QS logout, Right-click for rofi power menu";
          format = " ⏻ ";
          "on-click" = "qs-wlogout";
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
        };
      }
    ];

    style = concatStrings [
      ''
          * {
            font-size: 16px;
            font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
            font-weight: bold;
          }
          window#waybar {
            background-color: #282936;
            border-bottom: 1px solid #282936;
            border-radius: 0px;
            color: #00f769;
          }
          #workspaces {
            background: #3a3c4e;
            margin: 4px;
            padding: 0px 1px;
            border-radius: 10px;
            border: 0px;
            font-style: normal;
            color: #282936;
          }
          #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 10px;
            border: 0px;
            color: #282936;
            background: linear-gradient(45deg, #b45bcf, #00f769, #62d6e8, #b45bcf);
            background-size: 300% 300%;
            animation: gradient_horizontal 15s ease infinite;
            opacity: 0.5;
            transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }
          #workspaces button.active {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 10px;
            border: 0px;
            color: #282936;
            background: linear-gradient(45deg, #b45bcf, #00f769, #62d6e8, #b45bcf);
            background-size: 300% 300%;
            animation: gradient_horizontal 15s ease infinite;
            transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
            opacity: 1.0;
            min-width: 40px;
          }
          #workspaces button:hover {
            border-radius: 10px;
            color: #282936;
            background: linear-gradient(45deg, #b45bcf, #00f769, #62d6e8, #b45bcf);
            background-size: 300% 300%;
            animation: gradient_horizontal 15s ease infinite;
            opacity: 0.8;
            transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }
          @keyframes gradient_horizontal {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
          }
          @keyframes swiping {
            0% { background-position: 0% 200%; }
            100% { background-position: 200% 200%; }
          }
          tooltip {
            background: #282936;
            border: 1px solid #b45bcf;
            border-radius: 10px;
          }
          tooltip label { color: #f7f7fb; }
          #window {
            margin: 4px;
            padding: 2px 10px;
            color: #62d6e8; /* match pulseaudio blue */
            background: #3a3c4e;
            border-radius: 10px;
          }
          #memory {
            color: #00f769;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #clock {
            color: #ebff87;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #cpu {
            color: #f7f7fb;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #disk {
            color: #626483;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #battery {
            color: #ea51b2;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #network {
            color: #b45bcf;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #custom-hyprbindings {
            color: #b45bcf;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #tray {
            color: #e9e9f4;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #pulseaudio {
            color: #62d6e8;
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 10px;
            border-radius: 10px;
          }
          #custom-notification {
            color: #00f769; /* default green like jak-catppuccin */
            background: #3a3c4e;
            margin: 4px;
            padding: 2px 8px;
            border-radius: 10px;
          }
          /* Turn red on new alerts (match class names used by format-icons) */
          #custom-notification.notification,
          #custom-notification.dnd-notification,
          #custom-notification.inhibited-notification {
            color: #f38ba8; /* catppuccin red tone */
          }
          #custom-startmenu {
          color: #00f769;
          background: transparent;
          margin: 2px;
          padding: 3px 5px;
          border-radius: 10px;
        }
          /* Match qs icons to startmenu color/background */
          #custom-qs_wallpapers_apply,
          #custom-qs_vid_wallpapers_apply {
            color: #00f769;
            background: transparent;
            margin: 7px;
            padding: 3px 8px;
            border-radius: 10px;
          }
          /* Inside the QS group, make the two buttons sit closer */
          #group-qs_wallpapers { margin: 0; padding: 0; }
          #group-qs_wallpapers > * { margin: 0; }
          /* Tighten QS buttons margins/padding to bring them closer */
          #custom-qs_wallpapers_apply,
          #custom-qs_vid_wallpapers_apply {
            margin: 2px 2px;
            padding: 2px 4px;
          }
          #idle_inhibitor {
            color: #b45bcf;
            background: #3a3c4e;
            margin: 4px 0px;
            padding: 2px 14px;
            border-radius: 10px;
          }
          #custom-power {
            color: #ea51b2; /* Red color for power menu */
            background: #3a3c4e;
            margin: 4px 4px;
            padding: 10px 10px;
            border-radius: 10px;
          }
      ''
    ];
  };
}
