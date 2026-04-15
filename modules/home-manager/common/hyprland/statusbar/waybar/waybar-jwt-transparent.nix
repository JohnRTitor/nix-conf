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
          "custom/swaync"
          "idle_inhibitor"
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

        "custom/menu" = {
          format = "  ";
          # on-click = "pkill rofi || rofi -show drun -modi run,drun,filebrowser,window";
          on-click = "launch-nwg-menu";
          on-click-middle = "$HOME/.config/hypr/UserScripts/WallpaperSelect.sh";
          on-click-right = "$HOME/.config/hypr/scripts/WaybarLayout.sh";
          tooltip = true;
          tooltip-format = "Left Click: Rofi Menu\nMiddle Click: Wallpaper Menu\nRight Click: Waybar Layout Menu";
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

    # Transparent style based on transparent.css
    style = ''
      * {
        font-family: "Hack Nerd Font";
        font-weight: 400;
        font-size: 18px;
        border-radius: 7px;
      }

      window#waybar {
        background-color: transparent;
        color: #ffffff;
        border-radius: 8px;
      }

      #waybar > box {
        margin: 4px 8px 0 8px;
        padding: 2px;
        background-color: rgba(0, 0, 0, 0.1);
        border-radius: 8px;
      }

      tooltip {
        background: rgb(30, 30, 46);
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

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.1);
        border-radius: 7px;
      }

      /* Hyprland workspaces - based on working waybar-jak-catppuccin */
      #workspaces button {
        color: #74c7ec; /* default/inactive workspaces - sapphire */
        background-color: transparent;
        padding-top: 4px;
        padding-bottom: 4px;
        padding-right: 6px;
        padding-left: 4px;
      }

      #workspaces button.active {
        color: #a6e3a1; /* active workspace - green */
        background: transparent;
        border-radius: 15px;
      }

      #workspaces button.focused {
        color: #f5e0dc; /* focused workspace - rosewater */
        background: transparent;
        border-radius: 15px;
      }

      #workspaces button.urgent {
        color: #11111b; /* crust */
        background: transparent;
        border-radius: 15px;
      }

      #workspaces button:hover {
        background: transparent;
        color: #f2cdcd; /* flamingo */
        border-radius: 15px;
      }

      #workspaces button.empty {
        color: #f38ba8; /* empty workspace - red */
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
      #custom-power #power-profiles-daemon,
      #custom-cava,
      #custom-cava_mviz,
      #custom-gpt,
      #custom-menu,
      #custom-qs-wallpaper,
      #custom-qs-vid-wallpaper,
      #custom-swaync,
      #mpd {
        background: rgba(30, 30, 46, 0);
        padding: 1px 10px 1px 10px;
      }

      #window,
      #workspaces {
        color: #f5e0dc;
        padding: 1px 1px 1px 1px;
      }

      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }

      #clock {
        color: #ffffff;
        margin-right: 5px;
      }

      #clock:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-weather {
        color: #ffffff;
        padding: 1px 6px 1px 8px;
      }

      #custom-weather:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-spotify {
        color: #ffffff;
        padding: 1px 6px 1px 8px;
      }

      #custom-spotify:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-cava,
      #custom-cava_mviz {
        background: rgb(30, 30, 46);
        color: #ffffff;
        padding: 1px 10px;
        margin-left: 8px;
      }

      #custom-cava:hover,
      #custom-cava_mviz:hover {
        background-color: #181825;
      }

      #custom-gpt {
        font-size: 20px;
        background-position: center;
        background-repeat: no-repeat;
        background-size: 15px 15px;
        color: #ffffff;
        border-radius: 7px;
      }

      #custom-gpt:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #cava-player .status {
        font-size: 18px;
        color: #ffffff;
      }

      #custom-power {
        color: #ffffff;
        padding: 1px 5px 1px 3px;
        margin-right: 1px;
      }

      #custom-power:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-menu {
        color: #89b4fa;
        padding: 1px 10px 1px 10px;
        margin-left: 5px;
      }

      #custom-menu:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-qs-wallpaper,
      #custom-qs-vid-wallpaper {
        color: #74c7ec;
      }

      #custom-qs-wallpaper:hover,
      #custom-qs-vid-wallpaper:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #custom-swaync {
        color: #a6e3a1;
      }

      #custom-swaync.notification,
      #custom-swaync.dnd-notification,
      #custom-swaync.inhibited-notification,
      #custom-swaync.dnd-inhibited-notification {
        color: #f38ba8;
      }

      #custom-swaync:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #battery {
        color: #ffffff;
      }

      #battery.charging,
      #battery.plugged {
        color: #85eb81;
      }

      #battery:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      @keyframes blink {
        to {
          background: rgb(30, 30, 46);
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
        background: rgb(30, 30, 46);
      }

      #memory {
        color: #ffffff;
        padding: 1px 9px 1px 5px;
      }

      #memory:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #disk {
        background: rgb(30, 30, 46);
      }

      #backlight {
        color: #ffffff;
      }

      #network {
        color: #ffffff;
      }

      #network.disconnected {
        color: #f2564b;
      }

      #network:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #pulseaudio {
        color: #ffffff;
      }

      #pulseaudio.muted {
        color: #ffffff;
      }

      #wireplumber {
        color: #000000;
      }

      #pulseaudio:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #wireplumber.muted {
        background: rgb(30, 30, 46);
        padding: 1px 10px 1px 10px;
        margin-top: 5px;
      }

      #custom-media {
        color: #2a5c45;
        min-width: 100px;
      }

      #custom-media.custom-spotify {
        background: rgb(30, 30, 46);
        padding: 1px 10px 1px 10px;
        margin-top: 5px;
      }

      #custom-media.custom-vlc {
        background: rgb(30, 30, 46);
        margin-top: 5px;
      }

      #temperature {
        color: #ffffff;
      }

      #temperature.critical {
        background-color: #eb4d4b;
      }

      #temperature:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #tray {
        background-color: #2980b9;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }

      /* Idle inhibitor - coffee mug color changes */
      #idle_inhibitor {
        color: #f38ba8; /* default red (deactivated) */
      }

      #idle_inhibitor.activated {
        color: #a6e3a1; /* green when activated */
      }

      #idle_inhibitor.deactivated {
        color: #f38ba8; /* red when deactivated */
      }

      #idle_inhibitor:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }
    '';
  };
}
