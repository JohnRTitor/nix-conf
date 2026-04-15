{ pkgs, ... }:
let
  scriptsDir = ../waybar/scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);

  waybarCava = pkgs.writeShellScriptBin "WaybarCava" ''
    set -euo pipefail
    if ! command -v cava >/dev/null 2>&1; then
      echo "cava not found in PATH" >&2
      exit 1
    fi
    bar="▁▂▃▄▅▆▇█"
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
    cleanup() { rm -f "$config_file" "$pidfile"; }
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

  cfg = {
    layer = "top";
    exclusive = true;
    passthrough = false;
    position = "top";
    spacing = 3;
    "fixed-center" = true;
    ipc = true;
    "margin-top" = 3;
    "margin-left" = 8;
    "margin-right" = 8;

    modules-left = [
      "custom/separator#line"
      "custom/startmenu"
      "custom/qs_wallpapers_apply"
      "custom/separator#blank"
      "custom/qs_vid_wallpapers_apply"
      "custom/separator#line"
      "custom/separator#blank"
      "custom/cava_mviz"
      "custom/separator#blank"
      "custom/separator#line"
      "tray"
      "custom/separator#line"
    ];

    # Remove Hyprland-specific modules for MangoWC
    modules-center = [
      "custom/separator#line"
      "custom/playerctl"
      "custom/separator#line"
    ];

    modules-right = [
      "custom/separator#line"
      "custom/swaync"
      "custom/separator#line"
      "idle_inhibitor"
      "custom/separator#line"
      "clock"
      "custom/separator#line"
      "custom/weather"
      "custom/separator#line"
      "group/audio"
      "custom/separator#line"
      "custom/power"
    ];

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

    bluetooth = {
      format = " ";
      "format-disabled" = "󰂳";
      "format-connected" = "󰂱 {num_connections}";
      "tooltip-format" = " {device_alias}";
      "tooltip-format-connected" = "{device_enumerate}";
      "tooltip-format-enumerate-connected" = " {device_alias} 󰂄{device_battery_percentage}%";
      tooltip = true;
      "on-click" = "blueman-manager";
    };

    clock = {
      interval = 1;
      format = " {:%I:%M %p}";
      "format-alt" = " {:%H:%M   %Y, %d %B, %A}";
      "tooltip-format" = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "year";
        "mode-mon-col" = 3;
        "weeks-pos" = "right";
        "on-scroll" = 1;
        format = {
          months = "<span color='#ffead3'><b>{}</b></span>";
          days = "<span color='#ecc6d9'><b>{}</b></span>";
          weeks = "<span color='#99ffdd'><b>W{:%V}</b></span>";
          weekdays = "<span color='#ffcc66'><b>{}</b></span>";
          today = "<span color='#ff6699'><b><u>{}</u></b></span>";
        };
      };
      actions = {
        "on-click-right" = "mode";
        "on-click-forward" = "tz_up";
        "on-click-backward" = "tz_down";
        "on-scroll-up" = "shift_up";
        "on-scroll-down" = "shift_down";
      };
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

    idle_inhibitor = {
      tooltip = true;
      "tooltip-format-activated" = "Idle_inhibitor active";
      "tooltip-format-deactivated" = "Idle_inhibitor not active";
      format = "{icon}";
      "format-icons" = {
        activated = " ";
        deactivated = " ";
      };
    };

    "keyboard-state" = {
      capslock = true;
      format = {
        numlock = "N {icon}";
        capslock = "󰪛 {icon}";
      };
      "format-icons" = {
        locked = "";
        unlocked = "";
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

    network = {
      format = "{ifname}";
      "format-wifi" = "{icon}";
      "format-ethernet" = "󰌘";
      "format-disconnected" = "󰌙";
      "tooltip-format" = "{ipaddr}  {bandwidthUpBits}  {bandwidthDownBits}";
      "format-linked" = "󰈁 {ifname} (No IP)";
      "tooltip-format-wifi" = "{essid} {icon} {signalStrength}%";
      "tooltip-format-ethernet" = "{ifname} 󰌘";
      "tooltip-format-disconnected" = "󰌙 Disconnected";
      "max-length" = 30;
      "format-icons" = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
      "on-click-right" = "$HOME/.config/hypr/scripts/WaybarScripts.sh --nmtui";
    };

    "network#speed" = {
      interval = 1;
      format = "{ifname}";
      "format-wifi" = "{icon}  {bandwidthUpBytes}  {bandwidthDownBytes}";
      "format-ethernet" = "󰌘  {bandwidthUpBytes}  {bandwidthDownBytes}";
      "format-disconnected" = "󰌙";
      "tooltip-format" = "{ipaddr}";
      "format-linked" = "󰈁 {ifname} (No IP)";
      "tooltip-format-wifi" = "{essid} {icon} {signalStrength}%";
      "tooltip-format-ethernet" = "{ifname} 󰌘";
      "tooltip-format-disconnected" = "󰌙 Disconnected";
      "min-length" = 24;
      "max-length" = 24;
      "format-icons" = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
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

    "custom/weather" = {
      return-type = "json";
      exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ~/.config/mangowc/waybar/scripts/Weather.py'";
      interval = 600;
      tooltip = true;
    };

    "custom/file_manager" = {
      format = " ";
      "on-click" = "$HOME/.config/hypr/scripts/WaybarScripts.sh --files";
      tooltip = true;
      "tooltip-format" = "File Manager";
    };
    "custom/tty" = {
      format = " ";
      "on-click" = "$HOME/.config/hypr/scripts/WaybarScripts.sh --term";
      tooltip = true;
      "tooltip-format" = "Launch Terminal";
    };
    "custom/browser" = {
      format = " ";
      "on-click" = "xdg-open https://";
      tooltip = true;
      "tooltip-format" = "Launch Browser";
    };
    "custom/settings" = {
      format = " ";
      "on-click" = "$HOME/.config/hypr/scripts/Kool_Quick_Settings.sh";
      tooltip = true;
      "tooltip-format" = "Launch KooL Settings Menu";
    };

    "custom/qs_wallpapers_apply" = {
      format = " ";
      "on-click" = "qs-wallpapers-apply";
      tooltip = true;
      "tooltip-format" = "Set wallpaper";
    };
    "custom/qs_vid_wallpapers_apply" = {
      format = " ";
      "on-click" = "qs-vid-wallpapers-apply";
      tooltip = true;
      "tooltip-format" = "Set video wallpaper";
    };

    "custom/light_dark" = {
      format = "󰔎 ";
      "on-click" = "$HOME/.config/hypr/scripts/DarkLight.sh";
      "on-click-right" = "$HOME/.config/hypr/scripts/WaybarStyles.sh";
      tooltip = true;
      "tooltip-format" = "Left Click: Switch Dark-Light Themes\nRight Click: Waybar Styles Menu";
    };
    "custom/lock" = {
      format = "󰌾";
      "on-click" = "$HOME/.config/hypr/scripts/LockScreen.sh";
      tooltip = true;
      "tooltip-format" = "󰷛 Screen Lock";
    };
    "custom/menu" = {
      format = "  ";
      "on-click" = "launch-nwg-menu";
      "on-click-right" = "$HOME/.config/hypr/scripts/WaybarLayout.sh";
      tooltip = true;
      "tooltip-format" = "Left Click: App Menu\nRight Click: Waybar Layout Menu";
    };
    "custom/startmenu" = {
      tooltip = true;
      "tooltip-format" = "App menu";
      format = "";
      on-click = "launch-nwg-menu";
    };

    "custom/cava_mviz" = {
      exec = "${waybarCava}/bin/WaybarCava";
      format = "<span color='#a6e3a1'>[</span> {} <span color='#a6e3a1'>]</span>";
    };

    "custom/playerctl" = {
      format = "<span>{}</span>";
      "return-type" = "json";
      "max-length" = 25;
      exec = "playerctl -a metadata --format '{\"text\": \"{{artist}}  {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
      "on-click-middle" = "playerctl play-pause";
      "on-click" = "playerctl previous";
      "on-click-right" = "playerctl next";
      "scroll-step" = 5.0;
      "on-scroll-up" = "$HOME/.config/hypr/scripts/Volume.sh --inc";
      "on-scroll-down" = "$HOME/.config/hypr/scripts/Volume.sh --dec";
      "smooth-scrolling-threshold" = 1;
    };

    "custom/power" = {
      format = " ⏻ ";
      "on-click" = "qs-wlogout";
      "on-click-right" = "~/.config/mangowc/waybar/scripts/power-menu.sh";
      tooltip = true;
      "tooltip-format" = "Power menu: Left-click for QS logout, Right-click for rofi power menu";
    };

    "custom/quit" = {
      format = "󰗼";
      "on-click" = "loginctl kill-session $XDG_SESSION_ID";
      tooltip = true;
      "tooltip-format" = "Left Click: Logout";
    };

    "custom/swaync" = {
      tooltip = true;
      "tooltip-format" = "Left Click: Launch Notification Center\nRight Click: Do not Disturb";
      format = "{} {icon} ";
      "format-icons" = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        "dnd-notification" = "<span foreground='red'><sup></sup></span>";
        "dnd-none" = "";
        "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
        "inhibited-none" = "";
        "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
        "dnd-inhibited-none" = "";
      };
      "return-type" = "json";
      "exec-if" = "which swaync-client";
      exec = "swaync-client -swb";
      "on-click" = "systemctl --user start swaync.service; swaync-client -t";
      "on-click-right" = "systemctl --user start swaync.service; swaync-client -d";
      escape = true;
    };

    "custom/separator#line" = {
      format = "|";
      interval = "once";
      tooltip = false;
    };
    "custom/separator#blank" = {
      format = "";
      interval = "once";
      tooltip = false;
    };
  };

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

      * { font-family: "JetBrainsMono Nerd Font"; font-weight: bold; min-height: 0; font-size: 101%; }
      window#waybar { background-color: @base; border-radius: 5px; }
      tooltip { background: @base; opacity: 1; border-radius: 10px; border-width: 2px; border-style: solid; border-color: @sapphire; }
      tooltip label { color: @blue; }
      #custom-startmenu { color: @green; margin-left: 4px; margin-right: 8px; }
      #custom-cava_mviz { margin-left: 4px; }
      #workspaces button { color: @sapphire; }
      #workspaces button.active { color: @green; }
      #workspaces button.empty { color: @red; }
      #idle_inhibitor.activated { color: @green; }
      #idle_inhibitor.deactivated { color: @red; }
      #custom-power { color: @red; }
      #network { color: @mauve; }
      #custom-weather { color: @green; }
      #pulseaudio { color: @blue; }
      #clock { color: @green; }
      #custom-playerctl { color: @lavender; }
    '';

  mangowcWaybar = pkgs.writeShellScriptBin "mangowc-waybar" ''
    exec waybar -c "$HOME/.config/mangowc/waybar/config.jsonc" -s "$HOME/.config/mangowc/waybar/style.css"
  '';
in
{
  # Install scripts under ~/.config/mangowc/waybar/scripts
  home.file =
    builtins.listToAttrs (
      map (name: {
        name = ".config/mangowc/waybar/scripts/" + name;
        value = {
          source = "${scriptsDir}/${name}";
          executable = true;
        };
      }) scripts
    )
    // {
      ".config/mangowc/waybar/config.jsonc".text = builtins.toJSON [ cfg ];
      ".config/mangowc/waybar/style.css".text = style;
    };

  home.packages = [
    mangowcWaybar
    waybarCava
  ];
}
