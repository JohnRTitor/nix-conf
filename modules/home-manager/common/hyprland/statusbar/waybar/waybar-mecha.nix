{
  lib,
  pkgs,
  config,
  ...
}:
let
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
in
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
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        reload_style_on_change = true;
        "gtk-layer-shell" = true;
        modules-left = [
          "custom/startmenu"
          "custom/left1"
          "hyprland/workspaces"
          "custom/right1"
          "custom/paddw"
          "hyprland/window"
        ];
        modules-center = [
          "custom/paddc"
          "custom/left2"
          "custom/temperature"
          "custom/left3"
          "memory"
          "custom/left4"
          "cpu"
          "custom/leftin1"
          "custom/left5"
          "custom/distro"
          "custom/right2"
          "custom/rightin1"
          "idle_inhibitor"
          "custom/weather"
          "clock#time"
          "custom/right3"
          "clock#date"
          "custom/right4"
          "custom/right5"
        ];
        modules-right = [
          "mpris"
          "custom/left6"
          "pulseaudio"
          "custom/left7"
          "backlight"
          "custom/left8"
          "battery"
          "custom/leftin2"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          on-scroll-up = "hyprctl dispatch workspace -1";
          on-scroll-down = "hyprctl dispatch workspace +1";
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "hyprland/window" = {
          swap-icon-label = false;
          format = "{}";
          tooltip = false;
          min-length = 5;
          rewrite = {
            "" = "<span foreground='#89b4fa'> </span> Hyprland";
            "~" = " Terminal";
            "zsh" = " Terminal";
            "kitty" = " Terminal";
            "tmux(.*)" = "<span foreground='#a6e3a1'> </span> Tmux";
            "(.*)Mozilla Firefox" = "<span foreground='#f38ba8'>󰈹 </span> Firefox";
            "(.*) �� Mozilla Firefox" = "<span foreground='#f38ba8'>󰈹 </span> $1";
            "(.*)Zen Browser" = "<span foreground='#fab387'>󰺕 </span> Zen Browser";
            "(.*) — Zen Browser" = "<span foreground='#fab387'>󰺕 </span> $1";
            "(.*) - Visual Studio Code" = "<span foreground='#89b4fa'>󰨞 </span> $1";
            "(.*)Visual Studio Code" = "<span foreground='#89b4fa'>󰨞 </span> Visual Studio Code";
            "nvim" = "<span foreground='#a6e3a1'> </span> Neovim";
            "nvim (.*)" = "<span foreground='#a6e3a1'> </span> $1";
            "vim" = "<span foreground='#a6e3a1'> </span> Vim";
            "vim (.*)" = "<span foreground='#a6e3a1'> </span> $1";
            "(.*)Spotify" = "<span foreground='#a6e3a1'> </span> Spotify";
            "(.*)Spotify Premium" = "<span foreground='#a6e3a1'> </span> Spotify Premium";
            "OBS(.*)" = "<span foreground='#a6adc8'>󰻃 </span> OBS Studio";
            "VLC media player" = "<span foreground='#fab387'>󰕼 </span> VLC Media Player";
            "(.*) - VLC media player" = "<span foreground='#fab387'>󰕼 </span> $1";
            "(.*) - mpv" = "<span foreground='#cba6f7'> </span> $1";
            "qView" = "󰋩 qView";
            "(.*).jpg" = "󰋩 $1.jpg";
            "(.*).png" = "󰋩 $1.png";
            "(.*).svg" = "󰋩 $1.svg";
            "• Discord(.*)" = "Discord$1";
            "(.*)Discord(.*)" = "<span foreground='#89b4fa'> </span> $1Discord$2";
            "vesktop" = "<span foreground='#89b4fa'> </span> Discord";
            "ONLYOFFICE Desktop Editors" = "<span foreground='#f38ba8'> </span> OnlyOffice Desktop";
            "(.*).docx" = "<span foreground='#89b4fa'>󰈭 </span> $1.docx";
            "(.*).xlsx" = "<span foreground='#a6e3a1'>󰈜 </span> $1.xlsx";
            "(.*).pptx" = "<span foreground='#fab387'>󰈨 </span> $1.pptx";
            "(.*).pdf" = "<span foreground='#f38ba8'> </span> $1.pdf";
            "Authenticate" = " Authenticate";
          };
        };

        "custom/startmenu" = {
          format = "";
          tooltip = true;
          "tooltip-format" = "App menu";
          # on-click = "rofi -show drun";
          on-click = "launch-nwg-menu";
          "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
        };

        "custom/temperature" = {
          exec = "~/.config/waybar/scripts/cpu-temp.sh";
          return-type = "json";
          format = "{}";
          interval = 5;
          min-length = 8;
          max-length = 8;
        };

        memory = {
          states = {
            warning = 75;
            critical = 90;
          };
          format = "󰘚 {percentage}%";
          "format-critical" = "󰀦 {percentage}%";
          tooltip = false;
          interval = 5;
          min-length = 7;
          max-length = 7;
        };

        cpu = {
          format = "󰍛 {usage}%";
          tooltip = false;
          interval = 5;
          min-length = 6;
          max-length = 6;
        };

        "custom/distro" = {
          format = " ";
          tooltip = false;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
          "tooltip-format-activated" = "Presentation Mode";
          "tooltip-format-deactivated" = "Idle Mode";
          "start-activated" = false;
        };

        "custom/weather" = {
          "return-type" = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
        };

        "clock#time" = {
          format = "{:%H:%M}";
          tooltip = false;
          min-length = 6;
          max-length = 6;
        };

        "clock#date" = {
          format = "󰸗 {:%m-%d}";
          "tooltip-format" = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            "mode-mon-col" = 6;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#b4befe'><b>{}</b></span>";
              weekdays = "<span color='#a6adc8' font='7'>{}</span>";
              today = "<span color='#f38ba8'><b>{}</b></span>";
            };
          };
          actions = {
            "on-click" = "mode";
            "on-click-right" = "mode";
          };
          min-length = 8;
          max-length = 8;
        };

        "custom/wifi" = {
          exec = "~/.config/waybar/scripts/wifi-status.sh";
          return-type = "json";
          format = "{}";
          on-click = "~/.config/waybar/scripts/wifi-menu.sh";
          "on-click-right" = "kitty --title '󰤨 Network Manager TUI' bash -c nmtui";
          interval = 1;
          min-length = 1;
          max-length = 1;
        };

        bluetooth = {
          format = "󰂰";
          "format-disabled" = "󰂲";
          "format-connected" = "󰂱";
          "format-connected-battery" = "󰂱";
          "tooltip-format" = "{num_connections} connected";
          "tooltip-format-disabled" = "Bluetooth Disabled";
          "tooltip-format-connected" = "{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}";
          "tooltip-format-enumerate-connected-battery" = ":: {device_alias}: 󱊣 {device_battery_percentage}%";
          on-click = "~/.config/waybar/scripts/bluetooth-menu.sh";
          "on-click-right" = "kitty --title '󰂯 Bluetooth TUI' bash -c bluetui";
          interval = 1;
          min-length = 1;
          max-length = 1;
        };

        mpris = {
          format = "{player_icon} {title} - {artist}";
          "format-paused" = "{status_icon} {title} - {artist}";
          "player-icons" = {
            default = "󰝚 ";
            spotify = "<span foreground='#a6e3a1'>󰓇 </span>";
            firefox = "<span foreground='#f38ba8'>󰗃 </span>";
          };
          "status-icons" = {
            paused = "<span color='#b4befe'>\u200A\u200A󰏤\u2009\u2009</span>";
          };
          "tooltip-format" = "Playing: {title} - {artist}";
          "tooltip-format-paused" = "Paused: {title} - {artist}";
          min-length = 5;
          max-length = 35;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          "format-muted" = "󰝟 {volume}%";
          "format-icons" = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            headphone = "󰋋";
            headset = "󰋋";
          };
          "tooltip-format" = "Device: {desc}";
          on-click = "~/.config/waybar/scripts/volume-control.sh -o m";
          "on-scroll-up" = "~/.config/waybar/scripts/volume-control.sh -o i";
          "on-scroll-down" = "~/.config/waybar/scripts/volume-control.sh -o d";
          min-length = 6;
          max-length = 6;
        };

        backlight = {
          format = "{icon} {percent}%";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = false;
          "on-scroll-up" = "~/.config/waybar/scripts/brightness-control.sh -o i";
          "on-scroll-down" = "~/.config/waybar/scripts/brightness-control.sh -o d";
          min-length = 6;
          max-length = 6;
        };

        battery = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          "format-icons" = [
            "󰂎"
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
          "format-charging" = " {capacity}%";
          "tooltip-format" = "Discharging: {time}";
          "tooltip-format-charging" = "Charging: {time}";
          interval = 1;
          min-length = 6;
          max-length = 6;
        };

        "custom/power" = {
          format = " ⏻ ";
          tooltip = true;
          "tooltip-format" = "Power menu: Left-click for QS logout, Right-click for rofi power menu";
          "on-click" = "qs-wlogout";
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
        };

        "custom/paddw" = {
          format = " ";
          tooltip = false;
        };

        "custom/paddc" = {
          format = " ";
          tooltip = false;
        };

        "custom/left1" = {
          format = "";
          tooltip = false;
        };
        "custom/left2" = {
          format = "";
          tooltip = false;
        };
        "custom/left3" = {
          format = "";
          tooltip = false;
        };
        "custom/left4" = {
          format = "";
          tooltip = false;
        };
        "custom/left5" = {
          format = "";
          tooltip = false;
        };
        "custom/left6" = {
          format = "";
          tooltip = false;
        };
        "custom/left7" = {
          format = "";
          tooltip = false;
        };
        "custom/left8" = {
          format = "";
          tooltip = false;
        };

        "custom/right1" = {
          format = "";
          tooltip = false;
        };
        "custom/right2" = {
          format = "";
          tooltip = false;
        };
        "custom/right3" = {
          format = "";
          tooltip = false;
        };
        "custom/right4" = {
          format = "";
          tooltip = false;
        };
        "custom/right5" = {
          format = "";
          tooltip = false;
        };

        "custom/leftin1" = {
          format = "";
          tooltip = false;
        };
        "custom/leftin2" = {
          format = "";
          tooltip = false;
        };

        "custom/rightin1" = {
          format = "";
          tooltip = false;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-weight: bold;
        font-size: 18px;
      }

      window#waybar {
        background-color: #${config.lib.stylix.colors.base00};
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces {
        background: #${config.lib.stylix.colors.base01};
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #${config.lib.stylix.colors.base05};
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
        background-color: #${config.lib.stylix.colors.base03};
        box-shadow: inherit;
        text-shadow: 0 0 2px rgba(0, 0, 0, 0.6);
      }

      #workspaces button.urgent {
        background-color: #${config.lib.stylix.colors.base08};
      }

      #mode {
        background-color: #${config.lib.stylix.colors.base01};
        border-bottom: 3px solid #${config.lib.stylix.colors.base05};
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpris {
        padding: 0 10px;
        color: #${config.lib.stylix.colors.base05};
        background-color: #${config.lib.stylix.colors.base01};
      }

      #window,
      #workspaces {
        margin: 0 4px;
      }

      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }

      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }

      #battery.charging, #battery.plugged {
        color: #${config.lib.stylix.colors.base0B};
        background-color: #${config.lib.stylix.colors.base01};
      }

      @keyframes blink {
        to {
          background-color: #${config.lib.stylix.colors.base01};
          color: #${config.lib.stylix.colors.base08};
        }
      }

      #battery.critical:not(.charging) {
        background-color: #${config.lib.stylix.colors.base08};
        color: #${config.lib.stylix.colors.base01};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #${config.lib.stylix.colors.base00};
      }

      #pulseaudio.muted {
        background-color: #${config.lib.stylix.colors.base01};
        color: #${config.lib.stylix.colors.base04};
      }

      #tray {
        background-color: #${config.lib.stylix.colors.base01};
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #${config.lib.stylix.colors.base09};
      }

      #idle_inhibitor.activated {
        background-color: #${config.lib.stylix.colors.base01};
        color: #${config.lib.stylix.colors.base0B};
      }
    '';
  };
}
