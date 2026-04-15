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
          "hyprland/window"
        ];
        "modules-center" = [ "clock" ];
        "modules-right" = [
          "tray"
          "cpu"
          "memory"
          "idle_inhibitor"
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
          "sort-by-number" = true;
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
      @define-color bg #${config.stylix.base16Scheme.base00};
      @define-color fg #${config.stylix.base16Scheme.base05};
      @define-color lbg #${config.stylix.base16Scheme.base01};
      @define-color yellow #${config.stylix.base16Scheme.base0A};
      @define-color lavender #${config.stylix.base16Scheme.base0E};
      @define-color peach #${config.stylix.base16Scheme.base0A};
      @define-color red #${config.stylix.base16Scheme.base08};
      @define-color green #${config.stylix.base16Scheme.base0B};
      @define-color blue #${config.stylix.base16Scheme.base0D};
      @define-color border #${config.stylix.base16Scheme.base02};

      * {
        min-height: 0;
        margin: 0px 0px 0px 0px;
        padding: 0;
        border-radius: 7px;
        font-family: "JetBrains Mono Nerd Font";
        font-size: 14pt;
        font-weight: 700;
        padding-bottom: 0px;
      }

      tooltip {
        background: @bg;
        border-radius: 7px;
        border: 2px solid @border;
      }

      #window {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 7px;
        border-radius: 3px;
        border-color: @lbg;
        background-color: @yellow;
        color: @bg;
      }

      window#waybar.empty #window {
        background-color: @bg;
        border-bottom: none;
        border-right: none;
      }

      window#waybar {
        background-color: @bg;
        color: @lavender;
      }

      /* Workspaces */
      @keyframes button_activate {
        from { opacity: .3 }
        to { opacity: 1.; }
      }

      #workspaces {
        margin: 0px 0px 0px 0px;
        border-radius: 3px;
        padding: 1px;
        background-color: @bg;
        color: @bg;
      }

      #workspaces button {
        margin: 0px 0px 0px 0px;
        border-radius: 3px;
        padding-left: 3px;
        padding-right: 9px;
        background-color: @bg;
        color: @fg;
      }

      #workspaces button.active {
        background-color:@blue;
        color: @bg;
      }

      #workspaces button.urgent {
        color: #F38BA8;
      }

      #workspaces button:hover {
        border: solid transparent;
      }

      #custom-gpu-util {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 7px;
        background-color: @bg;
        color: @fg;
      }

      #tray {
        margin: 0px 0px 0px 0px;
        border-radius: 3px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @bg;
        color: @fg;
      }

      #idle_inhibitor {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 12px;
        border-radius: 3px;
        background-color: @bg;
        color: @fg;
      }

      #network {
        margin: 5px 5px 2px 5px;
        padding-left: 10px;
        padding-right: 12px;
        border-radius: 7px;
        background-color: @bg;
        color: @lavender;
      }

      #network.linked {
        color: @peach;
      }
      #network.disconnected,
      #network.disabled {
        color: @red;
      }

      #custom-subs {
        color: @fg;
        margin: 5px 5px 2px 5px;
        padding-left: 10px;
        padding-right: 12px;
        border-radius: 3px;
        border-bottom: 2px solid @bg;
        border-right: 2px solid @bg;
        border-color: @lbg;
        background-color: @red;
      }

      #custom-spacer {
        background-color: @yellow;
      }

      #custom-cliphist {
        color: @peach;
        margin: 5px 5px 2px 5px;
        padding-left: 10px;
        padding-right: 12px;
        border-radius: 3px;
        background-color: @bg;
      }

      #custom-gpu-temp,
      #cpu,
      #memory,
      #custom-clipboard,
      #temperature {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 3px;
        color: @fg;
        background-color: @bg;
      }

      #custom-playerctl {
        margin: 5px 5px 2px 5px;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 3px;
        color: @fg;
        background-color: @bg;
      }

      #battery,
      #backlight,
      #bluetooth,
      #pulseaudio {
        margin-top: 5px;
        margin-bottom: 2px;
        color: @fg;
        background-color: @bg;
        border-top-right-radius: 0px;
        border-bottom-right-radius: 0px;
        border-top-left-radius: 3px;
        border-bottom-left-radius: 3px;
      }

      #battery,
      #bluetooth {
        margin-left: 0px;
        margin-right: 5px;
        padding-left: 7.5px;
        padding-right: 10px;
        border-top-left-radius: 0px;
        border-bottom-left-radius: 0px;
        border-top-right-radius: 3px;
        border-bottom-right-radius: 3px;
      }

      #backlight,
      #pulseaudio {
        margin-right: 0px;
        margin-left: 5px;
        padding-left: 10px;
        padding-right: 7.5px;
        border-top-right-radius: 0px;
        border-bottom-right-radius: 0px;
        border-top-left-radius: 3px;
        border-bottom-left-radius: 3px;
      }

      #clock {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 3px;
        color: @bg;
        background-color: @green;
      }

      #taskbar {
        border-radius: 0px 0px 0px 0;
        padding: 0 3px;
        margin: 0 0px;
        color: #ffffff;
        background-color: rgba(120,118,117,0.3);
      }
      #taskbar button {
        border-radius: 0px 0px 0px 0px;
        padding: 0 0 0 3px;
        margin: 3px 1;
        color: #ffffff;
        background-color: rgba(120,118,117,0.1);
      }
      #taskbar button.active {
        background-color: rgba(120,118,117,0.8);
      }

      #mode {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 3px;
        background-color: @bg;
        color: @peach;
      }
    '';
  };
}
