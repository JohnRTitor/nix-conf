{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) clock24h;
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
in
with lib;
{
  # Install any helper scripts shipped in modules/home/waybar/scripts into ~/.config/waybar/scripts
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
        exclusive = true;
        passthrough = false;
        "fixed-center" = true;
        ipc = true;

        height = 34;
        spacing = 0;
        margin = 2;
        "margin-top" = 0;
        "margin-bottom" = 0;
        "margin-left" = 0;
        "margin-right" = 0;

        modules-left = [
          "custom/startmenu"
          "custom/qs_wallpapers_apply"
          "custom/qs_vid_wallpapers_apply"
          "hyprland/workspaces"
          "idle_inhibitor"
          "tray"
          "mpd#2"
          "mpd#3"
          "mpd#4"
          "mpd"
        ];
        modules-center = [
          "cpu"
          "cpu#2"
          "memory"
          "memory#2"
          "disk"
          "disk#2"
        ];
        modules-right = [
          "custom/themes"
          "pulseaudio"
          "pulseaudio#2"
          "backlight"
          "backlight#2"
          "battery"
          "battery#2"
          "bluetooth"
          "bluetooth#2"
          "network"
          "network#2"
          "clock"
          "clock#2"
          "custom/power"
        ];

        # --- Modules (ported from provided BlackDog config) ---
        backlight = {
          interval = 2;
          format = "{icon}";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          "on-scroll-up" = "light -A 5%";
          "on-scroll-down" = "light -U 5%";
          "smooth-scrolling-threshold" = 1;
        };
        "backlight#2" = {
          interval = 2;
          format = "{percent}%";
          "on-scroll-up" = "light -A 5%";
          "on-scroll-down" = "light -U 5%";
          "smooth-scrolling-threshold" = 1;
        };

        battery = {
          interval = 60;
          "full-at" = 100;
          "design-capacity" = false;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          "format-charging" = "";
          "format-plugged" = "ﮣ";
          "format-full" = "";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          "format-time" = "{H}h {M}min";
          tooltip = true;
        };
        "battery#2" = {
          interval = 60;
          "full-at" = 100;
          "design-capacity" = false;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}%";
          "format-charging" = "{capacity}%";
          "format-plugged" = "{capacity}%";
          "format-full" = "Full";
          "format-alt" = "{time}";
          "format-time" = "{H}h {M}min";
          tooltip = true;
        };

        bluetooth = {
          format = "";
          "format-on" = "";
          "format-off" = "";
          "format-disabled" = "";
          "format-connected" = "";
          "format-connected-battery" = "";
          tooltip = true;
          "tooltip-format" = "{controller_alias}\t{controller_address}";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "on-click" = "$HOME/.config/hypr/scripts/rofi_bluetooth";
          "on-click-right" = "blueman-manager";
        };
        "bluetooth#2" = {
          format = "{status}";
          "format-on" = "{status}";
          "format-off" = "{status}";
          "format-disabled" = "{status}";
          "format-connected" = "{device_alias}";
          "format-connected-battery" = "{device_alias}, {device_battery_percentage}%";
          tooltip = true;
          "tooltip-format" = "{controller_alias}\t{controller_address}";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "on-click" = "$HOME/.config/hypr/scripts/rofi_bluetooth";
          "on-click-right" = "blueman-manager";
        };

        clock = {
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = "";
        };
        "clock#2" = {
          interval = 60;
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = if clock24h then "{:%H:%M}" else "{:%I:%M %p}";
          "format-alt" = "{:%a %b %d, %G}";
        };

        cpu = {
          interval = 5;
          format = "";
        };
        "cpu#2" = {
          interval = 5;
          format = "{usage}%";
        };

        "custom/themes" = {
          format = "";
          tooltip = false;
          "on-click" = "$HOME/.config/hypr/theme/theme.sh --pywal";
          "on-click-right" = "$HOME/.config/hypr/theme/theme.sh --default";
        };

        # Start menu aligned to project standard
        "custom/startmenu" = {
          tooltip = true;
          "tooltip-format" = "App menu";
          format = "";
          on-click = "launch-nwg-menu";
          "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
        };

        # Power menu aligned to project standard (qs-wlogout + rofi fallback)
        "custom/power" = {
          tooltip = true;
          "tooltip-format" = "Left Click: Power Menu (qs-wlogout)\nRight Click: Rofi Power Menu";
          format = " ⏻ ";
          on-click = "qs-wlogout";
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
        };

        disk = {
          interval = 30;
          format = "";
        };
        "disk#2" = {
          interval = 30;
          format = "{free}";
        };

        memory = {
          interval = 10;
          format = "";
        };
        "memory#2" = {
          interval = 10;
          format = "{used:0.1f}G";
        };

        # Optional Spotify module (kept from source; may require script)
        "custom/spotify" = {
          exec = "$HOME/.config/hypr/waybar/spotify";
          interval = 1;
          format = "{}";
          tooltip = true;
          "max-length" = 40;
          "on-click" = "playerctl play-pause";
          "on-click-middle" = "playerctl previous";
          "on-click-right" = "playerctl next";
          "on-scroll-up" = "playerctl position 05+";
          "on-scroll-down" = "playerctl position 05-";
          "smooth-scrolling-threshold" = 1;
        };

        # MPD transport cluster
        mpd = {
          interval = 2;
          "unknown-tag" = "N/A";
          format = "{artist} - {title} | 祥 {elapsedTime:%M:%S}";
          "format-disconnected" = "Disconnected";
          "format-paused" = "{artist} - {title}";
          "format-stopped" = "Stopped";
          "tooltip-format" = "MPD (connected)";
          "tooltip-format-disconnected" = "MPD (disconnected)";
          "on-click" = "mpc toggle";
          "on-scroll-up" = "mpc seek +00:00:01";
          "on-scroll-down" = "mpc seek -00:00:01";
          "smooth-scrolling-threshold" = 1;
        };
        "mpd#2" = {
          format = "玲";
          "format-disconnected" = "玲";
          "format-paused" = "玲";
          "format-stopped" = "玲";
          "on-click" = "mpc prev";
        };
        "mpd#3" = {
          interval = 1;
          format = "{stateIcon}";
          "format-disconnected" = "";
          "format-paused" = "{stateIcon}";
          "format-stopped" = "";
          "state-icons" = {
            paused = "";
            playing = "";
          };
          "on-click" = "mpc toggle";
        };
        "mpd#4" = {
          format = "怜";
          "format-disconnected" = "怜";
          "format-paused" = "怜";
          "format-stopped" = "怜";
          "on-click" = "mpc next";
        };

        network = {
          interval = 5;
          "format-wifi" = "直";
          "format-ethernet" = "";
          "format-linked" = "";
          "format-disconnected" = "睊";
          "format-disabled" = "睊";
          "tooltip-format" = " {ifname} via {gwaddr}";
          "on-click" = "$HOME/.config/hypr/scripts/rofi_network";
        };
        "network#2" = {
          interval = 5;
          "format-wifi" = "{essid}";
          "format-ethernet" = "{ipaddr}/{cidr}";
          "format-linked" = "{ifname} (No IP)";
          "format-disconnected" = "Disconnected";
          "format-disabled" = "Disabled";
          "format-alt" = " {bandwidthUpBits} |  {bandwidthDownBits}";
          "tooltip-format" = " {ifname} via {gwaddr}";
        };

        pulseaudio = {
          format = "{icon}";
          "format-muted" = "";
          "format-bluetooth" = "";
          "format-bluetooth-muted" = "";
          "format-source" = "";
          "format-source-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "ﳌ";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          "scroll-step" = 5.0;
          "on-click" = "pulsemixer --toggle-mute";
          "on-click-right" = "pulsemixer --toggle-mute";
          "smooth-scrolling-threshold" = 1;
        };
        "pulseaudio#2" = {
          format = "{volume}%";
          "format-muted" = "Mute";
          "format-bluetooth" = "{volume}%";
          "format-bluetooth-muted" = "Mute";
          "format-source" = "{volume}%";
          "scroll-step" = 5.0;
          "on-click" = "pulsemixer --toggle-mute";
          "on-click-right" = "pulsemixer --toggle-mute";
          "smooth-scrolling-threshold" = 1;
        };

        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = "";
            deactivated = "";
          };
          timeout = 30;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          "sort-by-number" = true;
          "active-only" = false;
          "format-icons" = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            urgent = "";
            focused = "";
            default = "";
          };
          on-click = "activate";
        };

        tray = {
          "icon-size" = 16;
          spacing = 10;
        };

        # ddubs wallpaper quick actions
        "custom/qs_wallpapers_apply" = {
          format = "";
          tooltip = true;
          "tooltip-format" = "Set image wallpaper";
          on-click = "qs-wallpapers-apply";
        };
        "custom/qs_vid_wallpapers_apply" = {
          format = "";
          tooltip = true;
          "tooltip-format" = "Set video wallpaper";
          on-click = "qs-vid-wallpapers-apply";
        };
      }
    ];

    # --- CSS (colors + styles from provided BlackDog theme, with startmenu selector updated) ---
    style = concatStrings [
      ''
        /** Colors (from colors.css) **/
        @define-color background      #0a0a0a;
        @define-color background-alt1 #181818;
        @define-color background-alt2 #232323;
        @define-color foreground      #ddd8d0;
        @define-color selected        #E29E5D;
        @define-color black           #0a0a0a;
        @define-color red             #C53A31;
        @define-color green           #867971;
        @define-color yellow          #8F847B;
        @define-color blue            #E29E5D;
        @define-color magenta         #7C7987;
        @define-color cyan            #A19993;
        @define-color white           #ddd8d0;

        /** Fonts **/
        * {
            font-family: "JetBrains Mono", "Symbols Nerd Font", Iosevka, archcraft, sans-serif;
            font-size: 14px;
        }

        /** Waybar Window **/
        window#waybar {
            background-color: @background;
            color: @foreground;
            border-bottom: 2px solid @background-alt1;
            transition-property: background-color;
            transition-duration: .5s;
        }
        window#waybar.hidden { opacity: 0.5; }

        /** Custom **/
        #custom-startmenu {
          background-color: @background-alt1;
          color: @magenta;
          font-size: 18px;
          border-radius: 0px 14px 0px 0px;
          margin: 0px 0px 0px 0px;
          padding: 2px 8px 2px 8px;
        }
        #custom-themes { background-color: @selected; }
        #custom-power {
          background-color: @red;
          font-size: 16px;
        }
        #custom-power, #custom-themes {
          color: @background;
          border-radius: 10px;
          margin: 6px 6px 6px 0px;
          padding: 2px 8px 2px 8px;
        }

        /** Idle Inhibitor **/
        #idle_inhibitor {
          background-color: @green;
          color: @background;
          border-radius: 10px;
          margin: 6px 0px 6px 6px;
          padding: 4px 6px;
        }
        #idle_inhibitor.deactivated { background-color: @red; }

        /** Tray **/
        #tray {
          background-color: @background-alt1;
          border-radius: 10px;
          margin: 6px 0px 6px 6px;
          padding: 4px 6px;
        }
        #tray > .passive { -gtk-icon-effect: dim; }
        #tray > .needs-attention { -gtk-icon-effect: highlight; }

        /** MPD **/
        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        #mpd { color: @foreground; font-size: 12px; font-weight: bold; }
        #mpd.disconnected, #mpd.stopped { color: @red; }
        #mpd.playing { color: @cyan; }
        #mpd.2 { border-radius: 10px 0px 0px 10px; margin: 6px 0px 6px 6px; padding: 4px 6px 4px 10px; }
        #mpd.3 { margin: 6px 0px 6px 0px; padding: 4px; }
        #mpd.4 { border-radius: 0px 10px 10px 0px; margin: 6px 6px 6px 0px; padding: 4px 10px 4px 6px; }
        #mpd.2,#mpd.3,#mpd.4 { background-color: @background-alt1; font-size: 14px; }

        /** Spotify **/
        #custom-spotify {
          background-color: @background-alt1;
          color: @foreground;
          border-radius: 10px;
          margin: 6px 0px 6px 6px;
          padding: 4px 8px;
          font-size: 12px;
          font-weight: bold;
        }
        #custom-spotify.paused { color: @foreground; }
        #custom-spotify.playing {
          background: linear-gradient(90deg, @magenta 25%, @red 50%, @yellow 75%, @cyan 100%);
          background-size: 300% 300%;
          animation: gradient 10s ease infinite;
          color: @background;
        }
        #custom-spotify.offline { color: @red; }

        /** CPU/Memory/Disk **/
        #cpu { color: @red; }
        #memory { color: @green; }
        #disk { color: @yellow; }

        /** Pulseaudio **/
        #pulseaudio { color: @blue; }
        #pulseaudio.bluetooth { color: @cyan; }
        #pulseaudio.muted { color: @red; }

        /** Backlight **/
        #backlight { color: @magenta; }

        /** Battery **/
        #battery { color: @cyan; }
        @keyframes blink { to { color: @foreground; } }
        #battery.critical:not(.charging) { background-color: @background-alt2; }
        #battery.2.critical:not(.charging) {
          background-color: @background-alt1;
          color: @red;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        /** Network **/
        #network { color: @yellow; }
        #network.disconnected, #network.disabled { color: @red; }

        /** Bluetooth **/
        #bluetooth { color: @green; }
        #bluetooth.disabled, #bluetooth.off { color: @red; }

        /** Clock **/
        #clock { color: @blue; }

        /** Workspaces **/
        #workspaces {
          background-color: @background;
          border-radius: 10px;
          margin-left: 6px;
          margin-bottom: 2px;
          padding: 0px;
        }
        #workspaces button { color: @foreground; }
        #workspaces button.active { color: @red; }
        #workspaces button.urgent { color: @green; }
        #workspaces button.hidden { color: @yellow; }

        /** Common style **/
        #backlight, #battery, #clock, #cpu, #disk, #memory, #pulseaudio, #network, #bluetooth {
          background-color: @background-alt2;
          border-radius: 10px 0px 0px 10px;
          margin: 6px 0px 6px 0px;
          padding: 4px 6px;
        }
        #backlight.2, #battery.2, #clock.2, #cpu.2, #disk.2, #memory.2, #pulseaudio.2, #network.2, #bluetooth.2 {
          background-color: @background-alt1;
          color: @foreground;
          font-size: 12px;
          font-weight: bold;
          border-radius: 0px 10px 10px 0px;
          margin: 6px 6px 6px 0px;
          padding: 5px 6px 4px 6px;
        }
      ''
    ];
  };
}
