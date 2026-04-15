{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [ waybar ];

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        "modules-left" = [
          "hyprland/workspaces"
          "temperature"
          "hyprland/window"
        ];
        "modules-center" = [ "custom/spacer" ];
        "modules-right" = [
          "tray"
          "cpu"
          "memory"
          "idle_inhibitor"
          "clock"
          "pulseaudio"
          "bluetooth"
        ];
        "hyprland/window" = {
          format = "{title}";
          "max-length" = 333;
          "seperate-outputs" = true;
        };
        clock = {
          format = "<span foreground='#282828'> </span><span>{:%I:%M %a %d}</span>";
          "tooltip-format" = "{calendar}";
          calendar = {
            mode = "month";
            "mode-mon-col" = 3;
            "on-scroll" = 1;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>{%W}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b>{}</b></span>";
            };
          };
          actions = {
            "on-click-middle" = "mode";
            "on-click-right" = "shift_up";
            "on-click" = "shift_down";
          };
        };
        cpu = {
          format = "<span foreground='#b8bb26'>󰯳</span> {usage}%";
        };
        memory = {
          format = "<span foreground='#d65d9e'>󰍛</span> {}%";
          interval = 1;
        };
        "custom/gpu-util" = {
          exec = "./scripts/gpu-util";
          format = "<span foreground='#67b0e8'>󰯿</span> {}";
          interval = 1;
        };
        "custom/gpu-temp" = {
          exec = "./scripts/gpu-temp";
          format = "<span foreground='#e57474'></span> {}";
          interval = 1;
        };
        temperature = {
          "hwmon-path" = "/sys/class/hwmon/hwmon1/temp1_input";
          "critical-threshold" = 80;
          format = "<span foreground='#83a598'></span> {temperatureC}°C";
          interval = 1;
        };
        "hyprland/workspaces" = {
          format = "{icon}";
          "active-only" = false;
          "sort-by-number" = false;
          "on-click" = "activate";
          "all-outputs" = false;
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
          };
        };
        network = {
          format = "󰤭 Off";
          "format-wifi" = "{essid} ({signalStrength}%)";
          "format-ethernet" = "<span foreground='#b48ead'>󰈀</span>";
          "format-disconnected" = "󰤭 Disconnected";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "tooltip-format-wifi" = "{essid}({signalStrength}%)  ";
          "tooltip-format-ethernet" = "󰈀 {ifname}";
          "tooltip-format-disconnected" = "Disconnected";
        };
        pulseaudio = {
          format = "<span foreground='#cc241d'>{icon}</span> {volume}%  {format_source}";
          "format-bluetooth" = "<span foreground='#b16286'>{icon}</span> {volume}%  {format_source}";
          "format-bluetooth-muted" = "<span foreground='#D699B6'>󰖁</span>  {format_source}";
          "format-muted" = "<span foreground='#7A8478'>󰖁</span>  {format_source}";
          "format-source" = "<span foreground='#E67E80'></span> {volume}%";
          "format-source-muted" = "<span foreground='#F38BA8'></span>";
          "format-icons" = {
            headphone = "";
            phone = "";
            portable = "";
            default = [
              ""
              ""
              ""
            ];
          };
          "on-click-left" = "pavucontrol";
          input = true;
        };
        "custom/playerctl" = {
          format = "{icon}  <span>{}</span>";
          "return-type" = "json";
          "max-length" = 333;
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} ~ {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          "on-click-middle" = "playerctl play-pause";
          "on-click" = "playerctl previous";
          "on-click-right" = "playerctl next";
          "format-icons" = {
            Playing = "<span foreground='#98BB6C'></span>";
            Paused = "<span foreground='#E46876'></span>";
          };
        };
        tray = {
          format = "<span foreground='#D3C6AA'>{icon}</span>";
          "icon-size" = 14;
          spacing = 5;
        };
        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = "󱠛";
            deactivated = "󱤱";
          };
        };
        "custom/subs" = {
          format = "<span foreground='#fbf1c7'>󰗃 </span> {}";
          exec = "/usr/local/bin/subsfile.sh";
          "on-click" = "vivaldi-stable https://youtube.com/thelinuxcast";
          "restart-interval" = 1;
        };
        "custom/spacer" = {
          format = " ";
        };
        "wlr/taskbar" = {
          format = "{name}";
          "icon-size" = 14;
          "icon-theme" = "Numix-Circle";
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = [ "Alacritty" ];
          "app_ids-mapping" = {
            firefoxdeveloperedition = "firefox-developer-edition";
          };
          rewrite = {
            "Firefox Web Browser" = "Firefox";
            "Foot Server" = "Terminal";
          };
        };
        bluetooth = {
          "on-click" = "./scripts/bluetooth-control";
          "on-click-right" = "./scripts/rofi-bluetooth";
          "on-click-middle" = "./scripts/rofi-bluetooth";
          format = "{icon}";
          interval = 15;
          "format-icons" = {
            on = "<span foreground='#43242B'></span>";
            off = "<span foreground='#76946A'>󰂲</span>";
            disabled = "󰂲";
            connected = "";
          };
          "tooltip-format" = "{device_alias} {status}";
        };
      };
    };
    style = ''
      @define-color background #${config.stylix.base16Scheme.base00};
      @define-color foreground #${config.stylix.base16Scheme.base05};
      @define-color border #${config.stylix.base16Scheme.base02};
      @define-color color1 #${config.stylix.base16Scheme.base01};
      @define-color color2 #${config.stylix.base16Scheme.base02};
      @define-color color3 #${config.stylix.base16Scheme.base03};
      @define-color color4 #${config.stylix.base16Scheme.base04};
      @define-color color5 #${config.stylix.base16Scheme.base05};
      @define-color color6 #${config.stylix.base16Scheme.base06};
      @define-color color7 #${config.stylix.base16Scheme.base07};
      @define-color color8 #${config.stylix.base16Scheme.base08};
      @define-color color9 #${config.stylix.base16Scheme.base09};
      @define-color color10 #${config.stylix.base16Scheme.base0A};
      @define-color color11 #${config.stylix.base16Scheme.base0B};
      @define-color color12 #${config.stylix.base16Scheme.base0C};
      @define-color color13 #${config.stylix.base16Scheme.base0D};
      @define-color color14 #${config.stylix.base16Scheme.base0E};
      @define-color color15 #${config.stylix.base16Scheme.base0F};

      * {
        min-height: 0;
        margin: 0;
        padding: 0;
        font-family: "JetBrains Mono Nerd Font";
        font-size: 14pt;
        font-weight: 700;
        padding-bottom: 0px;
      }

      tooltip {
        background: @background;
        border: 2px solid @border;
      }

      #window {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 7px;
        background-color: @color14;
        color: #282828;
      }

      window#waybar.empty #window {
        background-color: transparent;
        border-bottom: none;
        border-right: none;
      }

      window#waybar {
        background-color:@color14;
        color: @color2;
      }

      /* Workspaces */

      #workspaces {
        margin: 0px 0px 0px 0px;
        padding: 0px;
        background-color: @background;
        color: @color7;
      }

      #workspaces button {
        margin: 0px 0px 0px 0px;
        padding-left: 3px;
        padding-right: 9px;
        background-color: @background;
        color: @color7;
      }

      #workspaces button.active {
        padding: 0 2px 0 1px;
        color: @color3;
      }

      #workspaces button.urgent {
        color: @color9;
      }

      #custom-gpu-util {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @background;
        color: @foreground;
      }

      #tray {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @background;
        color: @foreground;
      }

      #idle_inhibitor {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 12px;
        background-color: @background;
        color: @foreground;
      }

      #idle_inhibitor.activated {
        color: @color9;
      }

      #network {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 12px;
        background-color: @background;
        color: @color11;
      }

      #network.linked {
        color: @color6;
      }
      #network.disconnected,
      #network.disabled {
        color: @color4;
      }

      #custom-subs {
        color: @foreground;
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 12px;
        border-bottom: 2px solid @background;
        border-right: 2px solid @background;
        border-color: @color8;
        background-color: @color13;
      }

      #custom-cliphist {
        color: @color14;
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 12px;
        background-color: @background;
      }

      #custom-gpu-temp,
      #custom-clipboard {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        color: @foreground;
        background-color: @background;
      }

      #cpu {
        margin: 0px 0px 0px 0px;
        padding-left: 6px;
        padding-right: 6px;
        color: @foreground;
        background-color: @background;
      }

      #custom-cpuicon {
        margin: 0px 0px 0px 0px;
        padding: 0px 10px 0px 10px;
        color: @color14;
        background-color: @background;
      }

      #custom-diskicon {
        margin: 0px 0px 0px 0;
        padding: 0 10px 0 10px;
        color: @color2;
        background-color: @background;
      }

      #disk {
        margin: 0px 0px 0px 0;
        padding-left: 0px;
        padding-right: 0px;
        color: @foreground;
        background-color: @background;
      }

      #custom-notification {
        background-color: @background;
        color: @color15;
        padding: 0 12px;
        margin-right: 0px;
        font-size: 14px;
        font-family: "JetBrainsMono Nerd Font";
      }

      #custom-memoryicon {
        margin: 0px 0px 0px 0px;
        color: @color4;
        padding: 0 11px 0 7px;
        background-color: @background;
      }

      #memory {
        margin: 0px 0px 0px 0px;
        padding-left: 5px;
        padding-right: 10px;
        color: @color4;
        background-color: @background;
      }

      #custom-tempicon {
        margin: 0px 0px 0px 0px;
        color: @color10;
        padding: 0 11px 0 8px;
        background-color: @background;
      }

      #temperature {
        margin: 0px 0px 0px 0px;
        padding-left: 5px;
        padding-right: 10px;
        color: @color10;
        background-color: @background;
      }

      #custom-playerctl {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        color: @foreground;
        background-color: @background;
      }

      #battery,
      #backlight,
      #bluetooth,
      #pulseaudio {
        margin-top: 0px;
        margin-bottom: 0px;
        color: @foreground;
        background-color: @background;
      }

      #pulseaudio {
        margin-top: 0px;
        margin-bottom: 0px;
        color: @color15;
        background-color: @background;
      }

      #battery,
      #bluetooth {
        margin-left: 0px;
        margin-right: 0px;
        padding-left: 0px;
        padding-right: 2px;
      }

      #backlight,
      #pulseaudio {
        margin-right: 0px;
        margin-left: 0px;
        padding-left: 10px;
        padding-right: 7.5px;
      }

      #clock {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        color: @color6;
        background-color: @background;
      }

      #custom-clockicon {
        margin: 0px 0 0px 0px;
        color: @color6;
        padding: 0 5px 0 10px;
        background-color: @background;
      }

      #taskbar {
        padding: 0 3px;
        margin: 0 0px;
        color: #ffffff;
        background-color: rgba(120,118,117,0.3);
      }
      #taskbar button {
        padding: 0 0 0 3px;
        margin: 0px 0px;
        color: #ffffff;
        background-color: rgba(120,118,117,0.1);
      }
      #taskbar button.active {
        background-color: rgba(120,118,117,0.8);
      }

      #mode {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @background;
        color: @color9;
      }
    '';
  };
}
