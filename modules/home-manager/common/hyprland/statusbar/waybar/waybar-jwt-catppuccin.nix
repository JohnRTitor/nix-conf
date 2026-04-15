{ pkgs, ... }:
let
  # Install any helper scripts shipped in modules/home/waybar/scripts into ~/.config/waybar/scripts
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);

  # Inline, improved Cava script packaged via Nix so we don't rely on an external bash file
  waybarCava = pkgs.writeShellScriptBin "WaybarCava" ''
    set -euo pipefail

    # Ensure cava exists
    if ! command -v cava >/dev/null 2>&1; then
      echo "cava not found in PATH" >&2
      exit 1
    fi

    # Characters for vertical bars (0..7)
    bar="▁▂▃▄▅▆▇█"

    # Build sed script that:
    # - strips semicolons (cava RAW ASCII delimiter)
    # - maps digits 0..7 to the corresponding glyph in $bar
    dict="s/;//g"
    bar_length=''${#bar}
    for ((i = 0; i < bar_length; i++)); do
      dict+=";s/$i/''${bar:$i:1}/g"
    done

    # Single-instance guard (kill prior instance cleanly)
    RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
    pidfile="$RUNTIME_DIR/waybar-cava.pid"
    if [ -f "$pidfile" ]; then
      oldpid=$(cat "$pidfile" || true)
      if [ -n "''${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
        kill "$oldpid" 2>/dev/null || true
        # Give the old pipeline a moment to exit
        sleep 0.1 || true
      fi
    fi
    echo $$ > "$pidfile"

    # Use a unique temporary config and clean it up on exit
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

    # Stream cava output and transform
    exec cava -p "$config_file" | sed -u "$dict"
  '';

  # Catppuccin Mocha palette
  catppuccinColors = {
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    overlay2 = "#9399b2";
    overlay1 = "#7f849c";
    overlay0 = "#6c7086";
    surface2 = "#585b70";
    surface1 = "#45475a";
    surface0 = "#313244";
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
  };
in
{
  # Ensure bundled Waybar scripts are installed under ~/.config/waybar/scripts
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
    enable = true;
    package = pkgs.waybar;

    settings = [
      {
        layer = "top";
        exclusive = true;
        passthrough = false;
        position = "top";
        height = 30;
        spacing = 4;
        "fixed-center" = true;
        ipc = true;
        "margin-top" = 3;
        "margin-left" = 8;
        "margin-right" = 8;

        modules-left = [
          "custom/startmenu"
          "hyprland/workspaces"
          "custom/cava_mviz"
          "battery"
        ];

        modules-center = [
          "clock"
          "custom/weather"
        ];

        modules-right = [
          "idle_inhibitor"
          "custom/swaync"
          "pulseaudio"
          "temperature"
          "backlight"
          "custom/qs-wallpaper"
          "custom/qs-vid-wallpaper"
          "custom/power"
        ];

        # ---------- Modules configuration ----------
        "hyprland/workspaces" = {
          format = "{name}";
          persistent-workspaces = {
            "*" = 10;
          };
        };

        # Integrated CAVA visualizer using the inline script above
        "custom/cava_mviz" = {
          exec = "${waybarCava}/bin/WaybarCava";
          format = "<span color='#a6e3a1'>[</span> {} <span color='#a6e3a1'>]</span>";
        };

        idle_inhibitor = {
          format = "{icon}";
          tooltip = true;
          tooltip-format-activated = "Idle inhibitor is active";
          tooltip-format-deactivated = "Idle inhibitor is inactive";
          format-icons = {
            activated = "☕";
            deactivated = "☕";
          };
        };

        "custom/qs-wallpaper" = {
          format = "  ";
          on-click = "qs-wallpapers-apply";
          tooltip = true;
          tooltip-format = "Set wallpaper";
        };

        "custom/qs-vid-wallpaper" = {
          format = "  ";
          on-click = "qs-vid-wallpapers-apply";
          tooltip = true;
          tooltip-format = "Set video wallpaper";
        };

        "custom/weather" = {
          return-type = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
        };

        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };

        memory = {
          format = "{}% ";
        };

        temperature = {
          critical-threshold = 80;
          hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          format = "{}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          interval = 3;
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        network = {
          format-wifi = "Connected   • ";
          on-click = "kitty --class floatwlmenu -e bash ~/.config/scripts/wireless-menu.sh";
          format-ethernet = "Connected 󰈀  • ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "No Internet  ";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon} ";
          format-bluetooth-muted = "  {icon} ";
          format-muted = " ";
          format-source = " {volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              " "
            ];
          };
          on-click = "pavucontrol";
        };

        "custom/swaync" = {
          tooltip = true;
          tooltip-format = "Left Click: Launch Notification Center\nRight Click: Do not Disturb";
          format = "{} {icon} ";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "systemctl --user start swaync.service; swaync-client -t";
          on-click-right = "systemctl --user start swaync.service; swaync-client -d";
          escape = true;
        };

        "custom/power" = {
          format = " ⏻ ";
          tooltip = false;
          on-click = "qs-wlogout";
        };
      }
    ];

    # Consolidated style (Catppuccin Mocha) with solid background
    style =
      let
        c = catppuccinColors;
      in
      ''
        @define-color rosewater ${c.rosewater};
        @define-color flamingo  ${c.flamingo};
        @define-color pink      ${c.pink};
        @define-color mauve     ${c.mauve};
        @define-color red       ${c.red};
        @define-color maroon    ${c.maroon};
        @define-color peach     ${c.peach};
        @define-color yellow    ${c.yellow};
        @define-color green     ${c.green};
        @define-color teal      ${c.teal};
        @define-color sky       ${c.sky};
        @define-color sapphire  ${c.sapphire};
        @define-color blue      ${c.blue};
        @define-color lavender  ${c.lavender};
        @define-color text      ${c.text};
        @define-color subtext1  ${c.subtext1};
        @define-color subtext0  ${c.subtext0};
        @define-color overlay2  ${c.overlay2};
        @define-color overlay1  ${c.overlay1};
        @define-color overlay0  ${c.overlay0};
        @define-color surface2  ${c.surface2};
        @define-color surface1  ${c.surface1};
        @define-color surface0  ${c.surface0};
        @define-color base      ${c.base};
        @define-color mantle    ${c.mantle};
        @define-color crust     ${c.crust};

        * {
          font-family: "Hack Nerd Font", "Font Awesome 6 Free", "Font Awesome 6 Brands", monospace;
          font-weight: 400;
          font-size: 18px;
          border-radius: 7px;
        }

        window#waybar {
          background-color: @base;
          color: #ffffff;
          border-radius: 0px;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        /* Override white color for idle_inhibitor specifically */
        window#waybar > box > #idle_inhibitor {
          color: #f38ba8; /* red by default */
        }

        window#waybar > box > #idle_inhibitor.activated {
          color: #a6e3a1; /* green when activated */
        }

        window#waybar > box > #idle_inhibitor.deactivated {
          color: #f38ba8; /* red when deactivated */
        }

        tooltip {
          background: @base;
          border-radius: 7px;
        }

        button {
          box-shadow: inset 0 3px transparent;
          border: none;
          border-radius: 0;
        }

        button:hover {
          background: inherit;
        }

        #pulseaudio:hover {
          background-color: @mantle;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.3);
          border-radius: 7px;
        }

        /* Hyprland workspaces - based on working waybar-jak-catppuccin */
        #workspaces button {
          color: @sapphire; /* default/inactive workspaces - pale blue */
          background-color: transparent;
          padding-top: 4px;
          padding-bottom: 4px;
          padding-right: 6px;
          padding-left: 4px;
        }

        #workspaces button.active {
          color: @green; /* active workspace - green */
          background: transparent;
          border-radius: 15px;
        }

        #workspaces button.focused {
          color: @rosewater; /* focused workspace - rosewater */
          background: transparent;
          border-radius: 15px;
        }

        #workspaces button.urgent {
          color: @crust;
          background: transparent;
          border-radius: 15px;
        }

        #workspaces button:hover {
          background: transparent;
          color: @flamingo;
          border-radius: 15px;
        }

        #workspaces button.empty {
          color: @red; /* empty workspace - red */
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #mode {
          background-color: #64727d;
          box-shadow: inset 0 0px #ffffff;
          background: rgba(5, 5, 5, 0.3);
          color: #000000;
          padding: 1px 10px 1px 10px;
          border-radius: 0px 0px 0px 0px;
          margin-top: 5px;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #custom-spotify,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #custom-waypaper,
        #tray,
        #mode,
        #custom-weather,
        #idle_inhibitor,
        #scratchpad,
        #power-profiles-daemon,
        #custom-cava,
        #custom-cava_mviz,
        #custom-gpt,
        #custom-mspowers,
        #custom-qs-wallpaper,
        #custom-qs-vid-wallpaper,
        #custom-swaync,
        #mpd {
          background: @base;
          padding: 1px 10px 1px 10px;
          margin-top: 5px;
        }

        #window,
        #workspaces {
          background: @base;
          color: @rosewater;
          padding: 1px 1px 1px 1px;
          margin-top: 5px;
        }

        .modules-left > widget:first-child > #workspaces {
          margin-left: 5px;
        }

        .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
        }

        #clock {
          color: @pink;
          margin-top: 5px;
          margin-right: 5px;
        }

        #custom-mspowers {
          color: @yellow;
          margin-top: 5px;
        }

        #clock:hover {
          background-color: @mantle;
        }

        #custom-weather {
          color: @sky;
          padding: 1px 6px 1px 8px;
        }

        #custom-spotify {
          color: @maroon;
          padding: 1px 6px 1px 8px;
        }

        #custom-waypaper:hover {
          background-color: @mantle;
        }

        #custom-cava,
        #custom-cava_mviz {
          background: @base;
          color: @mauve;
          padding: 1px 10px;
          margin-left: 8px;
        }

        #custom-cava:hover,
        #custom-cava_mviz:hover {
          background-color: @mantle;
        }

        #custom-gpt {
          font-size: 20px;
          background-position: center;
          background-repeat: no-repeat;
          background-size: 15px 15px;
          color: @mauve;
          border-radius: 7px;
        }

        #custom-gpt:hover {
          background-color: @mantle;
        }

        #custom-weather:hover {
          background-color: @mantle;
        }

        #cava-player .status {
          font-size: 18px;
          color: #ffffff;
        }

        #custom-power {
          color: @mauve;
          background-color: @base;
          margin-right: 5px;
          margin-top: 5px;
          padding: 1px 5px 1px 2px;
        }

        #custom-power:hover {
          background-color: @mantle;
        }

        #custom-menu {
          color: @blue;
          background-color: @base;
          margin-left: 5px;
          margin-top: 5px;
          padding: 1px 10px 1px 10px;
          font-size: 18px;
          min-width: 30px;
        }

        #custom-menu:hover {
          background-color: @mantle;
        }

        #custom-qs-wallpaper,
        #custom-qs-vid-wallpaper {
          color: @sapphire;
          background-color: @base;
          font-size: 18px;
          min-width: 20px;
        }

        #custom-qs-wallpaper:hover,
        #custom-qs-vid-wallpaper:hover {
          background-color: @mantle;
        }

        #custom-swaync {
          color: @green;
          background-color: @base;
        }

        #custom-swaync.notification,
        #custom-swaync.dnd-notification,
        #custom-swaync.inhibited-notification,
        #custom-swaync.dnd-inhibited-notification {
          color: @red;
        }

        #custom-swaync:hover {
          background-color: @mantle;
        }

        #battery {
          color: @mauve;
        }

        #battery.charging,
        #battery.plugged {
          color: @green;
        }

        @keyframes blink {
          to {
            background: @base;
            color: #000000;
            padding: 1px 10px 1px 10px;
            margin-top: 5px;
          }
        }

        #battery.critical:not(.charging) {
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #battery:hover {
          background-color: @mantle;
        }

        #power-profiles-daemon {
          padding-right: 15px;
          color: #000000;
        }

        #power-profiles-daemon.performance {
          color: #ffffff;
        }

        #power-profiles-daemon.balanced {
          color: #ffffff;
        }

        #power-profiles-daemon.power-saver {
          color: #000000;
        }

        label:focus {
          background: @base;
        }

        #memory {
          color: @yellow;
        }

        #memory:hover {
          background-color: @mantle;
        }

        #disk {
          background: @base;
        }

        #backlight {
          color: @green;
        }

        #backlight:hover {
          background-color: @mantle;
        }

        #network {
          color: @peach;
        }

        #network.disconnected {
          color: @red;
        }

        #network:hover {
          background-color: @mantle;
        }

        #pulseaudio {
          color: @peach;
        }

        #pulseaudio.muted {
          color: @peach;
        }

        #temperature {
          background: @base;
          color: @yellow;
          padding: 1px 10px 1px 10px;
          margin-top: 5px;
        }

        #temperature.critical {
          background-color: #eb4d4b;
        }

        /* Idle inhibitor - comprehensive targeting without !important */
        #idle_inhibitor,
        .idle_inhibitor,
        button#idle_inhibitor,
        .module#idle_inhibitor,
        window#waybar #idle_inhibitor,
        window#waybar .idle_inhibitor,
        window#waybar button#idle_inhibitor {
          color: #f38ba8; /* red when deactivated */
          background-color: #1e1e2e;
        }

        #idle_inhibitor.activated,
        .idle_inhibitor.activated,
        button#idle_inhibitor.activated,
        .module#idle_inhibitor.activated,
        window#waybar #idle_inhibitor.activated,
        window#waybar .idle_inhibitor.activated,
        window#waybar button#idle_inhibitor.activated {
          color: #a6e3a1; /* green when activated */
          background-color: #1e1e2e;
        }

        #idle_inhibitor.deactivated,
        .idle_inhibitor.deactivated,
        button#idle_inhibitor.deactivated,
        .module#idle_inhibitor.deactivated,
        window#waybar #idle_inhibitor.deactivated,
        window#waybar .idle_inhibitor.deactivated,
        window#waybar button#idle_inhibitor.deactivated {
          color: #f38ba8; /* red when deactivated */
          background-color: #1e1e2e;
        }

        #idle_inhibitor:hover {
          background-color: @mantle;
        }

      '';
  };
}
