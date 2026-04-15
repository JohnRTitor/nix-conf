{
  pkgs,
  config,
  lib,
  host,
  ...
}:
let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../../../hosts/${host}/variables.nix) clock24h;
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
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
  # Configure & Theme Waybar
  programs.waybar = {
    settings = [
      {
        layer = "top";
        position = "top";

        modules-center = [
          "hyprland/workspaces"
          "custom/weather"
        ];
        modules-left = [
          "custom/startmenu"
          "clock"
          "hyprland/window"
          "custom/sep_left"
          "custom/cava_mviz"
          "custom/sep_right"
        ];
        modules-right = [
          "pulseaudio"
          "cpu"
          "memory"
          "custom/notification"
          "idle_inhibitor"
          "custom/themeselector"
          "battery"
          "tray"
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
        "clock" = {
          format = if clock24h == true then " {:L%H:%M}" else " {:L%I:%M %p}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big><tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 25;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
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
        };
        "custom/cava_mviz" = {
          "exec" = "WaybarCava";
          "format" = "{}";
        };
        "custom/sep_left" = {
          format = " [";
          tooltip = false;
        };
        "custom/sep_right" = {
          format = "] ";
          tooltip = false;
        };
        "custom/themeselector" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && theme-selector";
        };
        "custom/power" = {
          tooltip = true;
          "tooltip-format" = "Power menu: Left-click for QS logout, Right-click for rofi power menu";
          format = " ⏻ ";
          "on-click" = "qs-wlogout";
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
        };
        "custom/startmenu" = {
          tooltip = true;
          "tooltip-format" = "App menu";
          format = "";
          # on-click = "rofi -show drun";
          on-click = "launch-nwg-menu";
          "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = " Bindings";
          on-click = "sleep 0.1 && list-keybinds";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
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
        "custom/weather" = {
          return-type = "json";
          exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.local/bin/weather'";
          interval = 600;
          tooltip = true;
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
              font-size: 18px;
              border-radius: 0px;
              border: none;
              min-height: 0px;
            }
            window#waybar {
              background: rgba(0,0,0,0);
            }
            #workspaces {
              color: #${config.lib.stylix.colors.base00};
              background: #${config.lib.stylix.colors.base01};
              margin: 4px 4px;
              padding: 5px 5px;
              border-radius: 16px;
            }
            #workspaces button {
              font-weight: bold;
              padding: 0px 5px;
              margin: 0px 3px;
              border-radius: 16px;
              color: #${config.lib.stylix.colors.base00};
              background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
              opacity: 0.5;
              transition: ${betterTransition};
            }
            #workspaces button.active {
              font-weight: bold;
              padding: 0px 5px;
              margin: 0px 3px;
              border-radius: 16px;
              color: #${config.lib.stylix.colors.base00};
              background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
              transition: ${betterTransition};
              opacity: 1.0;
              min-width: 40px;
            }
            #workspaces button:hover {
              font-weight: bold;
              border-radius: 16px;
              color: #${config.lib.stylix.colors.base00};
              background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
              opacity: 0.8;
              transition: ${betterTransition};
            }
            tooltip {
              background: #${config.lib.stylix.colors.base00};
              border: 1px solid #${config.lib.stylix.colors.base08};
              border-radius: 12px;
            }
            tooltip label {
              color: #${config.lib.stylix.colors.base08};
            }
            #window, #pulseaudio, #cpu, #memory, #idle_inhibitor {
              font-weight: bold;
              margin: 4px 0px;
              margin-left: 7px;
              padding: 0px 18px;
              background: #${config.lib.stylix.colors.base00};
              color: #${config.lib.stylix.colors.base08};
              border-radius: 8px 8px 8px 8px;
            }
            #idle_inhibitor {
            font-size: 28px;
            }
            #custom-startmenu {
              color: #${config.lib.stylix.colors.base0B};
              background: #${config.lib.stylix.colors.base02};
              font-size: 22px;
              margin: 0px;
              padding: 0px 5px 0px 5px;
              border-radius: 16px 16px 16px 16px;
            }
            #custom-hyprbindings, #network, #battery,
            #custom-notification, #tray, #custom-power {
              /* font-weight: bold; */
              font-size: 20px;
              background: #${config.lib.stylix.colors.base00};
              color: #${config.lib.stylix.colors.base08};
              margin: 4px 0px;
              margin-right: 7px;
              border-radius: 8px 8px 8px 8px;
              padding: 0px 18px;
            }
            #clock {
              font-weight: bold;
              font-size: 16px;
              color: #0D0E15;
              background: linear-gradient(90deg, #${config.lib.stylix.colors.base0B}, #${config.lib.stylix.colors.base02});
              margin: 0px;
              padding: 0px 5px 0px 5px;
              border-radius: 16px 16px 16px 16px;
            }

          } ''
    ];
  };
}
