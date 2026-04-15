{
  pkgs,
  lib,
  ...
}:
with lib;
let
  # Install Waybar helper scripts under ~/.config/waybar/scripts (needed for power-menu.sh)
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);

  # Import upstream wallust color variables and base style from the source theme
  wallustColors = ''
    /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
     /* wallust template - colors-waybar */

     @define-color foreground #DADDF8;
     @define-color background #1A1921;
     @define-color background-alt rgba(26,25,33,0.25);
     @define-color cursor #7B7EA0;

     @define-color color0 #413F48;
     @define-color color1 #0F102E;
     @define-color color2 #151636;
     @define-color color3 #3F3683;
     @define-color color4 #404470;
     @define-color color5 #646AA1;
     @define-color color6 #7177B1;
     @define-color color7 #C2C7ED;
     @define-color color8 #888BA6;
     @define-color color9 #13153E;
     @define-color color10 #1C1E49;
     @define-color color11 #5448AF;
     @define-color color12 #555A95;
     @define-color color13 #868ED6;
     @define-color color14 #969FEC;
     @define-color color15 #C2C7ED;
  '';

  baseStyle = ''
    /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
    /* Oglo Chicklets */

    * {
        font-family: "JetBrainsMono Nerd Font", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        font-size: 97%;
        font-weight: bold;
    }

    window#waybar {
        background-color: #232a2e;
        border-bottom: 8px solid #1d2327;
        color: #d3c6aa;
        transition-property: background-color;
        transition-duration: .5s;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    /*
    window#waybar.empty {
        background-color: transparent;
    }
    window#waybar.solo {
        background-color: #FFFFFF;
    }
    */

    button {
        all: unset;
        background-color: #778f52;
        color: #2d353b;
        border: none;
        border-bottom: 8px solid #5d743e;
        border-radius: 5px;
        padding-left: 15px;
        padding-right: 15px;
        transition: transform 0.1s ease-in-out;
    }

    button:hover {
        background: inherit;
        background-color: #92ab6c;
        border-bottom: 8px solid #788f57;
    }

    button.active {
        background: inherit;
        background-color: #a5be7e;
        border-bottom: 8px solid #8aa168;
    }

    #mode {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
    }

    #backlight,
    #backlight-slider,
    #battery,
    #bluetooth,
    #clock,
    #cpu,
    #disk,
    #idle_inhibitor,
    #keyboard-state,
    #memory,
    #mode,
    #mpris,
    #network,
    #power-profiles-daemon,
    #pulseaudio,
    #pulseaudio-slider,
    #taskbar,
    #temperature,
    #tray,
    #window,
    #wireplumber,
    #workspaces,
    #custom-backlight,
    #custom-browser,
    #custom-cava_mviz,
    #custom-cycle_wall,
    #custom-dot_update,
    #custom-file_manager,
    #custom-keybinds,
    #custom-keyboard,
    #custom-light_dark,
    #custom-lock,
    #custom-hint,
    #custom-hypridle,
    #custom-menu,
    #custom-playerctl,
    #custom-power_vertical,
    #custom-power,
    #custom-quit,
    #custom-reboot,
    #custom-settings,
    #custom-spotify,
    #custom-swaync,
    #custom-tty,
    #custom-updater,
    #custom-hyprpicker,
    #custom-weather,
    #custom-weather.clearNight,
    #custom-weather.cloudyFoggyDay,
    #custom-weather.cloudyFoggyNight,
    #custom-weather.default,
    #custom-weather.rainyDay,
    #custom-weather.rainyNight,
    #custom-weather.severe,
    #custom-weather.showyIcyDay,
    #custom-weather.snowyIcyNight,
    #custom-weather.sunnyDay{
        color: #ffffff;
        padding-top: 2px;
        padding-bottom: 2px;
        border-radius: 5px;
    	padding-left: 5px;
    	padding-right: 5px;
    }

    #window,
    #workspaces {
        margin: 0 4px;
    }

    /* If workspaces is the leftmost module, omit left margin */
    .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
    }

    /* If workspaces is the rightmost module, omit right margin */
    .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
    }

    #window {
        background-color: #343f44;
        color: #d3c6aa;
        border-bottom: 8px solid #2b3539;
    }

    #custom-swaync {
        background-color: #778f52;
        color: #2d353b;
        border-bottom: 8px solid #5d743e;
    }

    #custom-menu {
        background-color: #778f52;
        color: #2d353b;
        border-bottom: 8px solid #5d743e;
    }

    #custom-power {
        background-color: #ee606a;
        color: #2d353b;
        border-bottom: 8px solid #ca4853;
        padding-left: 10px;
    }

    #custom-power_vertical{
        background-color: #ee606a;
        color: #2d353b;
        border-bottom: 8px solid #ca4853;
    }

    #clock {
        background-color: #96a84c;
        color: #2d353b;
        border-bottom: 8px solid #7a8c37;
    }

    #battery {
        background-color: #3a998f;
        color: #2d353b;
        border-bottom: 8px solid #227d74;
    }

    @keyframes blink {
        to {
            background-color: #ffffff;
            color: #000000;
        }
    }

    #battery.critical:not(.charging) {
        background-color: #ee606a;
        color: #2d353b;
        border-bottom: 8px solid #ca4853;
        animation-name: blink;
    	animation-duration: 3.0s;
    	animation-timing-function: steps(12);
    	animation-iteration-count: infinite;
    	animation-direction: alternate;
    }

    label:focus {
        background-color: #000000;
    }

    #cpu {
        background-color: #778f52;
        color: #2d353b;
        border-bottom: 8px solid #5d743e;
    }

    #memory {
        background-color: #d980ad;
        color: #2d353b;
        border-bottom: 8px solid #b86790;
    }

    #disk {
        background-color: #964B00;
        border-bottom: 8px solid #793300;
    }

    #custom-lock,
    #custom-light_dark,
    #backlight {
        background-color: #64b6ac;
        color: #2d353b;
        border-bottom: 8px solid #4f9990;
        padding-left: 10px;
    }

    #network {
        background-color: #2980b9;
    }

    #network.disconnected {
        background-color: #f53c3c;
    }

    #pulseaudio {
        background-color: #d8ac47;
        color: #2d353b;
        border-bottom: 8px solid #b78f30;
    }

    #pulseaudio.muted {
        background-color: #90b1b1;
        color: #2a5c45;
    }

    #wireplumber {
        background-color: #fff0f5;
        color: #000000;
    }

    #wireplumber.muted {
        background-color: #f53c3c;
    }

    #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
    }

    #custom-media.custom-spotify {
        background-color: #66cc99;
    }

    #custom-media.custom-vlc {
        background-color: #ffa000;
    }

    #temperature {
        background-color: #f0932b;
        border-bottom: 8px solid #b78f30;
    }

    #temperature.critical {
        background-color: #eb4d4b;
    }

    #tray {
        background-color: #e67f51;
        color: #2d353b;;
        border-bottom: 8px solid #c3653b;
    }

    #tray > .passive {
        -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
    }

    #idle_inhibitor {
        background-color: #2d3436;
    }

    #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
    }

    #mpd {
        background-color: #66cc99;
        color: #2a5c45;
    }

    #mpd.disconnected {
        background-color: #f53c3c;
    }

    #mpd.stopped {
        background-color: #90b1b1;
    }

    #mpd.paused {
        background-color: #51a37a;
    }

    #language {
        background: #00b093;
        color: #740864;
        min-width: 16px;
    }

    #keyboard-state {
        background: #97e1ad;
        color: #000000;
        min-width: 16px;
        border-bottom: 8px solid #78b48a;
    }

    #keyboard-state > label {
        padding: 0 5px;
    }

    #keyboard-state > label.locked {
        background: rgba(0, 0, 0, 0.2);
    }

    #scratchpad {
        background: rgba(0, 0, 0, 0.2);
    }

    #scratchpad.empty {
    	background-color: transparent;
    }

    tooltip {
      background-color: #232a2e;
      border: none;
      border-bottom: 8px solid #1d2327;
    }

    tooltip decoration {
      box-shadow: none;
    }

    tooltip decoration:backdrop {
      box-shadow: none;
    }

    tooltip label {
      color: #d3c6aa;
      padding-left: 5px;
      padding-right: 5px;
      padding-top: 0px;
      padding-bottom: 5px;
    }


    #pulseaudio-slider slider {
    	min-width: 0px;
    	min-height: 0px;
    	opacity: 0;
    	background-image: none;
    	border: none;
    	box-shadow: none;
    }

    #pulseaudio-slider trough {
    	background-color: #7f849c;
    	min-width: 80px;
    	min-height: 5px;
    	border-radius: 5px;
    }

    #pulseaudio-slider highlight {
    	min-height: 10px;
    	border-radius: 5px;
    }

    #backlight-slider slider {
    	min-width: 0px;
    	min-height: 0px;
    	opacity: 0;
    	background-image: none;
    	border: none;
    	box-shadow: none;
    }

    #backlight-slider trough {
    	background-color: #7f849c;
    	min-width: 80px;
    	min-height: 10px;
    	border-radius: 5px;
    }

    #backlight-slider highlight {
    	min-width: 10px;
    	border-radius: 5px;
    }
  '';

  # Explicit overrides for notification coffee mug colors (red when inactive/no notifications, green when active/has notifications)
  overrides = ''
    /* Coffee mug notification colors */
    #custom-swaync { color: #ee606a; } /* default red */
    #custom-swaync.none,
    #custom-swaync.dnd-none,
    #custom-swaync.inhibited-none { color: #ee606a; }
    #custom-swaync.notification,
    #custom-swaync.dnd-notification,
    #custom-swaync.inhibited-notification { color: #00f769; }
  '';
in
{
  # Install scripts (power-menu.sh, etc.)
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
        position = "top";
        # mode = "dock";
        exclusive = true;
        passthrough = false;
        "gtk-layer-shell" = true;
        "margin-left" = 6;
        "margin-right" = 6;
        "margin-top" = 2;

        # Layout
        "modules-left" = [
          "idle_inhibitor"
          "group/mobo_drawer"
          "hyprland/workspaces#rw"
          "tray"
          "mpris"
        ];
        "modules-center" = [
          "clock#2"
          "group/notify"
          "custom/weather"
        ];
        "modules-right" = [
          "hyprland/window"
          "battery"
          "group/audio"
          "custom/power"
        ];

        # Module definitions (subset needed by this layout)
        battery = {
          align = 0;
          rotate = 0;
          "full-at" = 100;
          "design-capacity" = false;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "format-plugged" = "󱘖 {capacity}%";
          "format-alt-click" = "click";
          "format-full" = "{icon} Full";
          "format-alt" = "{icon} {time}";
          "format-icons" = [
            "󰂎"
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
          "format-time" = "{H}h {M}min";
          tooltip = true;
          "tooltip-format" = "{timeTo} {power}w";
          "on-click-middle" = "$HOME/.config/hypr/scripts/ChangeBlur.sh";
          "on-click-right" = "$HOME/.config/hypr/scripts/Wlogout.sh";
        };

        "clock#2" = {
          format = " {:%I:%M %p}";
          "format-alt" = "{:%A  |  %H:%M  |  %e %B}";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "{usage}% 󰍛";
          interval = 1;
          "min-length" = 5;
          "format-alt-click" = "click";
          "format-alt" = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% 󰍛";
          "format-icons" = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          "on-click-right" = "gnome-system-monitor";
        };

        disk = {
          interval = 30;
          path = "/";
          format = "{percentage_used}% 󰋊";
          "tooltip-format" = "{used} used out of {total} on {path} ({percentage_used}%)";
        };

        "hyprland/workspaces#rw" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          "warp-on-scroll" = false;
          "sort-by-number" = true;
          "show-special" = false;
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
          "persistent-workspaces" = {
            "*" = 5;
          };
          format = "{icon} {windows}";
          "format-window-separator" = " ";
          "window-rewrite-default" = " ";
          "window-rewrite" = {
            "(.*) — Mozilla Firefox" = " $1";
            "(.*) - fish" = "> [$1]";
            "(.*) - zsh" = "> [$1]";
            "class<Warp|warp|dev.warp.Warp|warp-terminal>" = "󰰭 ";
            "class<com.mitchellh.ghostty>" = " 󰊠";
            "class<remote-viewer|virt-viewer>" = " ";
            "class<helium>" = " ";
            "class<[Ss]ignal|signal-desktop|org.signal.Signal>" = "󰍩 ";
            "title<.*Signal.*>" = "󰍩 ";
            "class<remmina|org.remmina.Remmina>" = "🖥️ ";
            "class<[Kk]denlive|org.kde.kdenlive>" = "🎬 ";
            "title<.*Kdenlive.*>" = "🎬 ";

            # qs-* apps
            "title<Hyprland Keybinds>" = " ";
            "title<Niri Keybinds>" = " ";
            "title<BSPWM Keybinds>" = " ";
            "title<DWM Keybinds>" = " ";
            "title<Emacs Leader Keybinds>" = " ";
            "title<Kitty Configuration>" = " ";
            "title<WezTerm Configuration>" = " ";
            "title<Yazi Configuration>" = " ";
            "title<Cheatsheets Viewer>" = " ";
            "title<Documentation Viewer>" = " ";
            "title<^Wallpapers$>" = " ";
            "title<^Video Wallpapers$>" = " ";
            "title<^qs-wlogout$>" = " ";

            # BoxBuddy
            "class<[Bb]ox[Bb]uddy|io.github.dvlv.boxbuddy|io.github.dvlv.BoxBuddy>" = " ";
            "title<.*BoxBuddy.*>" = " ";

            # Bazaar software store
            "class<io.github.kolunmi.Bazaar>" = " ";
            "title<^Bazaar$>" = " ";

            # satty screenshot tool
            "class<com.gabm.satty>" = " ";
            "title<^satty$>" = " ";
          };
        };

        "hyprland/window" = {
          format = "{}";
          "max-length" = 25;
          "separate-outputs" = true;
          "offscreen-css" = true;
          "offscreen-css-text" = "(inactive)";
        };

        idle_inhibitor = {
          tooltip = true;
          "tooltip-format-activated" = "Idle_inhibitor active";
          "tooltip-format-deactivated" = "Idle_inhibitor not active";
          format = "{icon}";
          "format-icons" = {
            activated = " ";
            deactivated = " ";
          };
        };

        memory = {
          interval = 10;
          format = "{used:0.1f}G 󰾆";
          "format-alt" = "{percentage}% 󰾆";
          "format-alt-click" = "click";
          tooltip = true;
          "tooltip-format" = "{used:0.1f}GB/{total:0.1f}G";
          "on-click-right" = "$HOME/.config/hypr/scripts/WaybarScripts.sh --btop";
        };

        "custom/weather" = {
          "return-type" = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
        };

        mpris = {
          interval = 10;
          format = "{player_icon} ";
          "format-paused" = "{status_icon} <i>{dynamic}</i>";
          "on-click-middle" = "playerctl play-pause";
          "on-click" = "playerctl previous";
          "on-click-right" = "playerctl next";
          "scroll-step" = 5.0;
          "on-scroll-up" = "$HOME/.config/hypr/scripts/Volume.sh --inc";
          "on-scroll-down" = "$HOME/.config/hypr/scripts/Volume.sh --dec";
          "smooth-scrolling-threshold" = 1;
          tooltip = true;
          "tooltip-format" =
            "{status_icon} {dynamic}\nLeft Click: previous\nMid Click: Pause\nRight Click: Next";
          "player-icons" = {
            chromium = "";
            default = "";
            firefox = "";
            kdeconnect = "";
            mopidy = "";
            mpv = "󰐹";
            spotify = "";
            vlc = "󰕼";
          };
          "status-icons" = {
            paused = "󰐎";
            playing = "";
            stopped = "";
          };
          "max-length" = 30;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          "format-bluetooth" = "{icon} 󰂰 {volume}%";
          "format-muted" = "󰖁";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              "󰕾"
              ""
            ];
            "ignored-sinks" = [ "Easy Effects Sink" ];
          };
          "scroll-step" = 5.0;
          "on-click" = "$HOME/.config/hypr/scripts/Volume.sh --toggle";
          "on-click-right" = "pavucontrol -t 3";
          "on-scroll-up" = "$HOME/.config/hypr/scripts/Volume.sh --inc";
          "on-scroll-down" = "$HOME/.config/hypr/scripts/Volume.sh --dec";
          "tooltip-format" = "{icon} {desc} | {volume}%";
          "smooth-scrolling-threshold" = 1;
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          "format-source" = " {volume}%";
          "format-source-muted" = "";
          "on-click" = "$HOME/.config/hypr/scripts/Volume.sh --toggle-mic";
          "on-click-right" = "pavucontrol -t 4";
          "on-scroll-up" = "$HOME/.config/hypr/scripts/Volume.sh --mic-inc";
          "on-scroll-down" = "$HOME/.config/hypr/scripts/Volume.sh --mic-dec";
          "tooltip-format" = "{source_desc} | {source_volume}%";
          "scroll-step" = 5;
        };

        tray = {
          "icon-size" = 20;
          spacing = 4;
        };

        # Groups
        "group/mobo_drawer" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 500;
            "children-class" = "cpu";
            "transition-left-to-right" = true;
          };
          modules = [
            "temperature"
            "cpu"
            "power-profiles-daemon"
            "memory"
            "disk"
          ];
        };

        "group/audio" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 500;
            "children-class" = "pulseaudio";
            "transition-left-to-right" = true;
          };
          modules = [
            "pulseaudio"
            "pulseaudio#microphone"
          ];
        };

        "group/notify" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 500;
            "children-class" = "custom/swaync";
            "transition-left-to-right" = false;
          };
          modules = [
            "custom/swaync"
            "custom/dot_update"
          ];
        };

        # Custom modules
        "custom/power" = {
          format = " ⏻ ";
          "on-click" = "qs-wlogout";
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
          tooltip = true;
          "tooltip-format" = "Power menu: Left-click for QS logout, Right-click for rofi power menu";
        };

        "custom/quit" = {
          format = "󰗼";
          "on-click" = "hyprctl dispatch exit";
          tooltip = true;
          "tooltip-format" = "Left Click: Exit Hyprland";
        };

        "custom/swaync" = {
          tooltip = true;
          "tooltip-format" = "Left Click: Launch Notification Center\nRight Click: Do not Disturb";
          format = "{} {icon} ";
          # Coffee mug icon for all states
          "format-icons" = {
            notification = "";
            none = "";
            "dnd-notification" = "";
            "dnd-none" = "";
            "inhibited-notification" = "";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          exec = "swaync-client -swb";
          "on-click" = "sleep 0.1 && swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          escape = true;
        };

        # Support modules referenced by groups
        temperature = {
          interval = 10;
          tooltip = true;
          "hwmon-path" = [
            "/sys/class/hwmon/hwmon1/temp1_input"
            "/sys/class/thermal/thermal_zone0/temp"
          ];
          "critical-threshold" = 82;
          "format-critical" = "{temperatureC}°C {icon}";
          format = "{temperatureC}°C {icon}";
          "format-icons" = [ "󰈸" ];
          "on-click-right" = "$HOME/.config/hypr/scripts/WaybarScripts.sh --nvtop";
        };

        "power-profiles-daemon" = {
          format = "{icon} ";
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          "format-icons" = {
            default = "";
            performance = "";
            balanced = "";
            "power-saver" = "";
          };
        };

        "custom/dot_update" = {
          format = " 󰁈 ";
          "on-click" = "$HOME/.config/hypr/scripts/KooLsDotsUpdate.sh";
          tooltip = true;
          "tooltip-format" = "Check KooL Dots update\nIf available";
        };
      }
    ];

    # Compose style: wallust colors first, then base style, then our overrides
    style = wallustColors + baseStyle + overrides;
  };
}
