{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  clockIs24h = config.myOptions.userSettings.${config.home.username}.clockType == "24h";
in
with lib;
{
  # Configure & Theme Waybar
  programs.waybar = {
    settings = [
      {
        layer = "top";
        position = "top";
        margin-top = 6;
        margin-left = 6;
        margin-right = 6;
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "cpu"
          "memory"
          "temperature"
          "disk"
          "hyprland/window"
          "idle_inhibitor"
        ];
        modules-right = [
          "pulseaudio"
          "battery"
          "custom/hyprbindings"
          "custom/notification"
          "clock"
          "tray"
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
        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        "temperature" = {
          format = " {temperatureC}°C ";
        };
        "clock" = {
          format = if clockIs24h then " {:L%H:%M}" else " {:L%I:%M %p}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          icon-size = 20;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = "󱛟 {free}";
          tooltip = true;
        };
        "network" = {
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
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
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
          scroll-step = 2;
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "";
          # exec = "rofi -show drun";
          #on-click = "sleep 0.1 && rofi-launcher";
          on-click = "sleep 0.1 && nwg-drawer -mb 200 -mt 200 -mr 200 -ml 200";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = "󱕴";
          on-click = "sleep 0.1 && list-keybinds";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
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
        "battery" = {
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
      }
    ];
    style = concatStrings [
      ''
        * {
          font-family: JetBrainsMono Nerd Font Mono;
          font-size: 16px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
          margin: 0px;
        }
        window#waybar {
          background: #${config.lib.stylix.colors.base00};
          padding: 2px;
          border-radius: 4px;
        }
        #workspaces {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base00};
          border: 2px solid #${config.lib.stylix.colors.base0B};
          margin: 2px 4px;
          padding: 5px 5px;
          border-radius: 4px;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base0B};
          background: #${config.lib.stylix.colors.base00};

        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 4px;
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base0B};
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 4px;
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base0B};
          opacity: 0.8;
        }
        tooltip {
          background: #${config.lib.stylix.colors.base00};
          border: 1px solid #${config.lib.stylix.colors.base08};
          border-radius: 12px;
        }
        tooltip label {
          color: #${config.lib.stylix.colors.base08};
        }
        #window, #pulseaudio, #temperature, #cpu, #memory, #idle_inhibitor, #disk {
          font-weight: bold;
          margin: 2px 0px;
          margin-right: 7px;
          padding: 0px 18px;
          background: #${config.lib.stylix.colors.base00};
          color: #${config.lib.stylix.colors.base0B};
          border: 2px solid #${config.lib.stylix.colors.base0B};
          border-radius: 4px;
        }
        #idle_inhibitor {
        font-size: 28px;
        }
        #custom-startmenu {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base0B};
          font-size: 22px;
          padding: 0px 5px 0px 5px;
          border-radius: 4px;
          padding: 0px 8px;
          margin: 0px;
          margin-right:7px;

        }
        #custom-hyprbindings, #network, #battery,
        #custom-notification, #clock, #custom-exit {
          /* font-weight: bold; */
          font-size: 20px;
          background: #${config.lib.stylix.colors.base00};
          color: #${config.lib.stylix.colors.base0B};
          margin: 2px 0px;
          margin-right: 7px;
          border: 2px solid #${config.lib.stylix.colors.base0B};
          border-radius: 4px;
          padding: 0px 12px;
        }
        #tray{
          font-weight: bold;
          font-size: 16px;
          margin: 0px;
          background: #${config.lib.stylix.colors.base0B};
          color: #${config.lib.stylix.colors.base00};
          border: 2px solid #${config.lib.stylix.colors.base0B};
          padding: 0px 18px;
          margin: 0px 0px;
          border-radius: 4px;
        }
      ''
    ];
  };
}
