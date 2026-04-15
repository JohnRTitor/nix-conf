{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  c = config.lib.stylix.colors;
  # Install helper scripts and provide an inline Waybar CAVA script like in Catppuccin config
  scriptsDir = ./scripts;
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
        # mode = "dock";
        exclusive = true;
        passthrough = false;
        position = "top";
        spacing = 3;
        "fixed-center" = true;
        ipc = true;
        "margin-top" = 3;
        "margin-left" = 8;
        "margin-right" = 8;

        "modules-left" = [
          "custom/startmenu"
          "group/app_drawer"
          "custom/separator#blank"
          "custom/cava_mviz"
          "custom/separator#blank"
          "custom/playerctl"
          "custom/separator#blank_2"
          "hyprland/window"
        ];

        "modules-center" = [
          "custom/separator#blank"
          "group/notify"
          "custom/separator#dot-line"
          "hyprland/workspaces#rw"
          "clock"
          "custom/separator#dot-line"
          "custom/separator#dot-line"
          "idle_inhibitor"
          "custom/weather"
        ];

        "modules-right" = [
          "tray"
          "custom/separator#dot-line"
          "group/laptop"
          "custom/separator#dot-line"
          "group/mobo_drawer"
          "custom/separator#line"
          "group/audio"
          "custom/separator#dot-line"
          "group/status"
        ];

        # Modules (from Modules)
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

        backlight = {
          interval = 2;
          align = 0;
          rotate = 0;
          "format-icons" = [
            " "
            " "
            " "
            "󰃝 "
            "󰃞 "
            "󰃟 "
            "󰃠 "
          ];
          format = "{icon}";
          "tooltip-format" = "backlight {percent}%";
          "icon-size" = 10;
          "on-scroll-up" = "$HOME/.config/hypr/scripts/Brightness.sh --inc";
          "on-scroll-down" = "$HOME/.config/hypr/scripts/Brightness.sh --dec";
          "smooth-scrolling-threshold" = 1;
        };

        "backlight#2" = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          "format-icons" = [
            ""
            ""
          ];
        };

        battery = {
          # bat = "BAT1";
          # adapter = "ACAD";
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
          format = " {:%I:%M %p}"; # AM/PM
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
        };

        "actions" = {
          "on-click-right" = "mode";
          "on-click-forward" = "tz_up";
          "on-click-backward" = "tz_down";
          "on-scroll-up" = "shift_up";
          "on-scroll-down" = "shift_down";
        };

        "cpu" = {
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

        "hyprland/language" = {
          format = "Lang: {}";
          "format-en" = "US";
          "format-tr" = "Korea";
          "keyboard-name" = "at-translated-set-2-keyboard";
          "on-click" = "hyprctl switchxkblayout $SET_KB next";
        };

        "hyprland/submap" = {
          format = ''<span style="italic">  {}</span>'';
          tooltip = false;
        };

        "hyprland/window" = {
          format = "{}";
          "max-length" = 25;
          "separate-outputs" = true;
          "offscreen-css" = true;
          "offscreen-css-text" = "(inactive)";
          rewrite = {
            "(.*) — Mozilla Firefox" = " $1";
            "(.*) - fish" = "> [$1]";
            "(.*) - zsh" = "> [$1]";
            "(.*) - $term" = "> [$1]";
          };
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
          "on-click-right" = "kitty -e btop";
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
          # "ignored-players" = [ "firefox" ];
          "max-length" = 30;
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
          "on-click-right" = " kitty -e nmtui";
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

        "wlr/taskbar" = {
          format = "{icon} {name}";
          "icon-size" = 16;
          "all-outputs" = false;
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = [
            "wofi"
            "rofi"
            "kitty"
            "kitty-dropterm"
          ];
        };

        # Modules (from ModulesCustom)
        "custom/weather" = {
          format = "{}";
          "format-alt" = "{alt}: {}";
          "format-alt-click" = "click";
          interval = 3600;
          "return-type" = "json";
          exec = "$HOME/.config/hypr/UserScripts/Weather.py";
          tooltip = true;
        };

        "custom/hyprpicker" = {
          format = "";
          "on-click" = "hyprpicker | wl-copy";
          tooltip = true;
          "tooltip-format" = "Hyprpicker";
        };

        "custom/hypridle" = {
          format = "󱫗 ";
          "return-type" = "json";
          escape = true;
          "exec-on-event" = true;
          interval = 60;
          exec = "$HOME/.config/hypr/scripts/Hypridle.sh status";
          "on-click" = "$HOME/.config/hypr/scripts/Hypridle.sh toggle";
          "on-click-right" = "hyprlock";
        };

        "custom/lock" = {
          format = "󰌾";
          "on-click" = "$HOME/.config/hypr/scripts/LockScreen.sh";
          tooltip = true;
          "tooltip-format" = "󰷛 Screen Lock";
        };

        "custom/menu" = {
          format = "  ";
          # "on-click" = "pkill rofi || rofi -show drun -modi run,drun,filebrowser,window";
          "on-click" = "launch-nwg-menu";
          "on-click-middle" = "$HOME/.config/hypr/UserScripts/WallpaperSelect.sh";
          "on-click-right" = "$HOME/.config/hypr/scripts/WaybarLayout.sh";
          tooltip = true;
          "tooltip-format" =
            "Left Click: Rofi Menu\nMiddle Click: Wallpaper Menu\nRight Click: Waybar Layout Menu";
        };

        "custom/cava_mviz" = {
          exec = "${waybarCava}/bin/WaybarCava";
          format = "{}";
        };

        "custom/playerctl" = {
          format = "<span>{}</span>";
          "return-type" = "json";
          "max-length" = 25;
          exec = ''playerctl -a metadata --format '{"text": "{{artist}}  {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
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
          "on-click-right" = "~/.config/waybar/scripts/power-menu.sh";
          tooltip = true;
          "tooltip-format" = "Left Click: Power Menu (qs-wlogout)\nRight Click: Rofi Power Menu";
        };

        "custom/reboot" = {
          format = "󰜉";
          "on-click" = "systemctl reboot";
          tooltip = true;
          "tooltip-format" = "Left Click: Reboot";
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
          "on-click" = "sleep 0.1 && swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          escape = true;
        };

        # Separators
        "custom/separator#dot" = {
          format = "";
          interval = "once";
          tooltip = false;
        };
        "custom/separator#dot-line" = {
          format = "";
          interval = "once";
          tooltip = false;
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
        "custom/separator#blank_2" = {
          format = "  ";
          interval = "once";
          tooltip = false;
        };
        "custom/separator#blank_3" = {
          format = "   ";
          interval = "once";
          tooltip = false;
        };

        # Groups (from ModulesGroups)
        "group/app_drawer" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 500;
            "children-class" = "custom/menu";
            "transition-left-to-right" = true;
          };
          modules = [
            "custom/menu"
            "custom/file_manager"
            "custom/tty"
            "custom/browser"
          ];
        };

        "group/motherboard" = {
          orientation = "horizontal";
          modules = [
            "cpu"
            "power-profiles-daemon"
            "memory"
            "temperature"
            "disk"
          ];
        };

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

        "group/laptop" = {
          orientation = "inherit";
          modules = [
            "backlight"
            "battery"
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

        "group/status" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 500;
            "children-class" = "custom/power";
            "transition-left-to-right" = false;
          };
          modules = [
            "custom/power"
            "custom/lock"
            "keyboard-state"
            "custom/keyboard"
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
          ];
        };

        # Workspaces (from ModulesWorkspaces)
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
            "title<.*amazon.*>" = " ";
            "title<.*reddit.*>" = " ";
            "title<.*[Hh]elium.*>" = " ";

            "class<firefox|org.mozilla.firefox|librewolf|floorp|mercury-browser|[Cc]achy-browser>" = " ";
            "class<zen>" = "󰰷 ";
            "class<waterfox|waterfox-bin>" = " ";
            "class<microsoft-edge>" = " ";
            "class<Chromium|Thorium|[Cc]hrome>" = " ";
            "class<helium>" = " ";
            "class<brave-browser>" = "🦁 ";
            "class<tor browser>" = " ";
            "class<firefox-developer-edition>" = "🦊 ";

            "class<kitty|konsole>" = " ";
            "class<kitty-dropterm>" = " ";
            "class<com.mitchellh.ghostty>" = " 󰊠";
            "class<org.wezfurlong.wezterm>" = " ";
            "class<Warp|warp|dev.warp.Warp|warp-terminal>" = "󰰭 ";

            "class<[Tt]hunderbird|[Tt]hunderbird-esr>" = " ";
            "class<eu.betterbird.Betterbird>" = " ";
            "title<.*gmail.*>" = "󰊫 ";

            "class<[Tt]elegram-desktop|org.telegram.desktop|io.github.tdesktop_x64.TDesktop>" = " ";
            "class<discord|discord-canary|[Ww]ebcord|[Vv]esktop|com.discordapp.Discord|dev.vencord.Vesktop>" =
              " ";
            "title<.*whatsapp.*>" = " ";
            "title<.*zapzap.*>" = " ";
            "title<.*messenger.*>" = " ";
            "title<.*facebook.*>" = " ";
            "class<[Ss]ignal|signal-desktop|org.signal.Signal>" = "󰍩 ";
            "title<.*Signal.*>" = "󰍩 ";

            "title<.*ChatGPT.*>" = "󰚩 ";
            "title<.*deepseek.*>" = "󰚩 ";
            "title<.*qwen.*>" = "󰚩 ";
            "class<subl>" = "󰅳 ";
            "class<slack>" = " ";

            "class<mpv>" = " ";
            "class<celluloid|Zoom>" = " ";
            "class<Cider>" = "󰎆 ";
            "title<.*Picture-in-Picture.*>" = " ";
            "title<.*youtube.*>" = " ";
            "class<vlc>" = "󰕼 ";
            "class<[Kk]denlive|org.kde.kdenlive>" = "🎬 ";
            "title<.*Kdenlive.*>" = "🎬 ";

            "class<[Bb]ox[Bb]uddy|io.github.dvlv.boxbuddy|io.github.dvlv.BoxBuddy>" = " ";
            "title<.*BoxBuddy.*>" = " ";

            # qs-* apps
            "class<Plex>" = "󰚺 ";

            "class<virt-manager>" = " ";
            "class<.virt-manager-wrapped>" = " ";
            "class<remote-viewer|virt-viewer>" = " ";
            "class<virtualbox manager>" = "💽 ";
            "title<virtualbox>" = "💽 ";
            "class<remmina|org.remmina.Remmina>" = "🖥️ ";

            "class<VSCode|code|code-url-handler|code-oss|codium|codium-url-handler|VSCodium>" = "󰨞 ";
            "class<dev.zed.Zed>" = "󰵁";
            "class<codeblocks>" = "󰅩 ";
            "title<.*github.*>" = " ";
            "class<mousepad>" = " ";
            "class<libreoffice-writer>" = " ";
            "class<libreoffice-startcenter>" = "󰏆 ";
            "class<libreoffice-calc>" = " ";
            "title<.*nvim ~.*>" = " ";
            "title<.*vim.*>" = " ";
            "title<.*nvim.*>" = " ";
            "title<.*Discord.*>" = " ";
            "title<.*figma.*>" = " ";
            "title<.*jira.*>" = " ";
            "class<jetbrains-idea>" = " ";

            "class<obs|com.obsproject.Studio>" = " ";

            "class<polkit-gnome-authentication-agent-1>" = "󰒃 ";
            "class<nwg-look>" = " ";
            "class<[Pp]avucontrol|org.pulseaudio.pavucontrol>" = "󱡫 ";
            "class<steam>" = " ";
            "class<thunar|nemo>" = "󰝰 ";
            "class<Gparted>" = "";
            "class<gimp>" = " ";
            "class<emulator>" = "📱 ";
            "class<android-studio>" = " ";
            "class<org.pipewire.Helvum>" = "󰓃";
            "class<localsend>" = "";
            "class<PrusaSlicer|UltiMaker-Cura|OrcaSlicer>" = "󰹛";

            "class<io.github.kolunmi.Bazaar>" = " ";
            "title<^Bazaar$>" = " ";

            "class<com.gabm.satty>" = " ";
            "title<^satty$>" = " ";

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
          };
        };
      }
    ];

    # Stylix-based CSS (replaces Wallust)
    style = ''
      /* ---- 💫 JakooLit ml4w-modern (Stylix) 💫 ---- */

      /* Define palette from Stylix base16 */
      @define-color backgroundlight #${c.base00};
      @define-color backgrounddark #${c.base02};
      @define-color workspacesbackground1 #${c.base00};
      @define-color workspacesbackground2 #${c.base02};
      @define-color bordercolor #${c.base0D};
      @define-color textcolor1 #${c.base05};
      @define-color textcolor2 #${c.base05};
      @define-color textcolor3 #${c.base05};
      @define-color iconcolor #${c.base05};
      @define-color accentgreen #${c.base0B};
      @define-color accentred #${c.base08};

      * {
        font-family: "JetBrainsMono Nerd Font";
        font-weight: bold;
        min-height: 0;
        font-size: 97%;
        font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
      }

      window#waybar {
        background-color: rgba(0,0,0,0.8);
        border-bottom: 0px solid #ffffff;
        background: transparent;
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces {
        background: @workspacesbackground1;
        margin: 2px 18px 3px 1px;
        margin-left: 6px;
        padding: 0px 2px;
        border-radius: 5px;
        border: 0px;
        font-style: normal;
        color: @textcolor1;
      }

      #workspaces button {
        padding: 0px 6px;
        margin: 3px 2px;
        border-radius: 3px;
        color: @textcolor1;
        background-color: @workspacesbackground1;
        transition: all 0.1s linear;
      }

      #workspaces button.active {
        color: @textcolor1;
        background: @workspacesbackground2;
        border-radius: 3px;
        min-width: 30px;
        transition: all 0.1s linear;
      }

      #workspaces button:hover {
        color: @textcolor1;
        background: @workspacesbackground2;
        border-radius: 5px;
        opacity: 0.7;
      }

      tooltip {
        border-radius: 16px;
        background-color: @backgroundlight;
        opacity: 0.9;
        padding: 20px;
        margin: 0px;
      }

      tooltip label { color: @textcolor2; }

      #window {
        margin: 3px 15px 3px 0px;
        padding: 2px 10px 0px 10px;
        border-radius: 5px;
        color: white;
        font-weight: normal;
      }

      window#waybar.empty #window { background-color: transparent; }

      #taskbar {
        background: @backgroundlight;
        margin: 3px 15px 3px 0px;
        padding: 0px;
        border-radius: 5px;
        font-weight: normal;
        font-style: normal;
        border: 3px solid @backgroundlight;
      }

      #taskbar button { margin: 0; border-radius: 5px; padding: 0px 5px; }
      #taskbar.empty { background: transparent; border: 0; padding: 0; margin: 0; }

      .modules-left > widget:first-child > #workspaces { margin-left: 0; }
      .modules-right > widget:last-child > #workspaces { margin-right: 0; }

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
      #taskbar button,
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
      #custom-weather.sunnyDay {
        margin-right: 8px;
        margin-left: 6px;
        font-size: 100%;
        color: @iconcolor;
      }

      #custom-swaync { margin-left: 12px; color: @accentgreen; }
      #custom-swaync.notification,
      #custom-swaync.dnd-notification,
      #custom-swaync.inhibited-notification { color: @accentred; }

      #idle_inhibitor {
        margin-right: 15px;
        font-size: 102%;
        font-weight: bold;
        color: @iconcolor;
      }

      #idle_inhibitor.activated {
        margin-right: 15px;
        font-size: 100%;
        font-weight: bold;
        color: @accentgreen;
      }

      #idle_inhibitor.deactivated {
        color: @accentred;
      }

      #custom-menu {
        background-color: @backgrounddark;
        color: @textcolor1;
        border-radius: 5px;
        padding: 0px 10px;
        margin: 2px 17px 2px 0px;
        border: 3px solid @bordercolor;
      }

      #custom-power {
        background-color: @backgrounddark;
        color: @textcolor1;
        border-radius: 5px;
        padding: 0px 0px 0px 6px;
        border: 3px solid @bordercolor;
      }

      #custom-keybinds { margin: 0px 13px 0px 0px; padding: 0px; color: @iconcolor; }

      #custom-updater {
        background-color: @backgroundlight;
        color: @textcolor2;
        border-radius: 5px;
        padding: 2px 10px 0px 10px;
        margin: 3px 15px 3px 0px;
      }

      #custom-updates.green { background-color: @backgroundlight; }
      #custom-updates.yellow { background-color: #ff9a3c; color: #FFFFFF; }
      #custom-updates.red { background-color: #dc2f2f; color: #FFFFFF; }

      #keyboard-state { margin-right: 10px; }

      #clock {
        background-color: @backgrounddark;
        color: @textcolor1;
        border-radius: 3px 5px 3px 5px;
        padding: 1px 10px 0px 10px;
        margin: 3px 0px 3px 0px;
        border: 3px solid @bordercolor;
      }

      #backlight {
        background-color: @backgroundlight;
        margin-left: 6px;
        color: @textcolor2;
        border-radius: 5px;
        padding: 2px 10px 0px 10px;
        margin: 3px 15px 3px 0px;
      }

      #pulseaudio {
        background-color: @backgroundlight;
        color: @textcolor2;
        border-radius: 5px;
        padding: 2px 10px 0px 10px;
        margin: 3px 15px 3px 0px;
      }

      #pulseaudio.muted { background-color: @backgrounddark; color: @textcolor1; }

      #network,
      #network.ethernet,
      #network.wifi,
      #bluetooth,
      #bluetooth.on,
      #bluetooth.connected,
      #battery {
        background-color: @backgroundlight;
        color: @textcolor2;
        border-radius: 5px;
        padding: 2px 10px 0px 10px;
        margin: 3px 15px 3px 0px;
      }

      #bluetooth.off { background-color: transparent; padding: 0px; margin: 0px; }

      #battery.charging, #battery.plugged { color: @textcolor2; background-color: @backgroundlight; }

      @keyframes blink { to { background-color: @backgroundlight; color: @textcolor2; } }
      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: @textcolor3;
        animation-name: blink;
        animation-duration: 3.0s;
        animation-timing-function: steps(12);
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #tray { padding: 0px 15px 0px 0px; }
      #tray > .passive { -gtk-icon-effect: dim; }
      #tray > .needs-attention { -gtk-icon-effect: highlight; }

      #backlight-slider slider,
      #pulseaudio-slider slider {
        min-width: 0px;
        min-height: 0px;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
      }

      #backlight-slider trough,
      #pulseaudio-slider trough { min-width: 80px; min-height: 5px; border-radius: 5px; }
      #backlight-slider highlight,
      #pulseaudio-slider highlight { min-height: 10px; border-radius: 5px; }

      /* --- Explicit color overrides to ensure correct states --- */
      /* SwayNC: green when no notifications, red when any notification state */
      #custom-swaync { color: #00f769; }
      #custom-swaync.none,
      #custom-swaync.dnd-none,
      #custom-swaync.inhibited-none { color: #00f769; }
      #custom-swaync.notification,
      #custom-swaync.dnd-notification,
      #custom-swaync.inhibited-notification { color: #f38ba8; }

      /* Idle inhibitor: red when deactivated, green when activated */
      #idle_inhibitor { color: #f38ba8; }
      #idle_inhibitor.deactivated { color: #f38ba8; }
      #idle_inhibitor.activated { color: #00f769; }
    '';
  };
}
