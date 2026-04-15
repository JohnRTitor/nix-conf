{ lib, config, ... }:
lib.mkIf (config.myOptions.programsSettings.statusbar == "hyprpanel") {
  programs.hyprpanel.enable = true;

  programs.hyprpanel.settings = {
    "bar.customModules.storage.paths" = [ "/" ];

    "menus.volume.raiseMaximumVolume" = true;
    "bar.battery.label" = false;
    "bar.battery.hideLabelWhenFull" = false;

    "bar.layouts" = {
      "0" = {
        left = [
          "dashboard"
          "cputemp"
          "workspaces"
          "windowtitle"
        ];
        middle = [
          "cava"
          "notifications"
          "netstat"
        ];
        right = [
          "volume"
          "network"
          "bluetooth"
          "systray"
          "clock"
          "power"
        ];
      };
      "1" = {
        left = [
          "dashboard"
          "workspaces"
          "windowtitle"
        ];
        middle = [ "media" ];
        right = [
          "volume"
          "clock"
          "notifications"
        ];
      };
      "2" = {
        left = [
          "dashboard"
          "workspaces"
          "windowtitle"
        ];
        middle = [ "media" ];
        right = [
          "volume"
          "clock"
          "notifications"
        ];
      };
    };

    "theme.matugen" = true;
    "wallpaper.pywal" = true;
    "wallpaper.enable" = true;
    "wallpaper.image" = ./Arch-chan_to.png;

    "theme.bar.menus.monochrome" = false;
    "theme.font.name" = "Inconsolata LGC Nerd Font";
    "theme.font.label" = "Inconsolata LGC Nerd Font";
    "theme.font.size" = "1.1rem";

    "scalingPriority" = "gdk";
    "theme.bar.floating" = false;
    "theme.bar.buttons.enableBorders" = false;
    "bar.autoHide" = "fullscreen";

    "menus.clock.weather.location" = "Kolkata";
    "theme.bar.margin_sides" = "0em";
    "tear" = true;

    "theme.bar.menus.enableShadow" = true;
    "theme.bar.menus.opacity" = 95;
    "theme.bar.menus.background" = "#5e5c64";

    "theme.bar.opacity" = 75;
    "theme.bar.buttons.opacity" = 80;
    "theme.bar.buttons.background_opacity" = 80;
    "theme.bar.buttons.background_hover_opacity" = 90;

    "menus.dashboard.shortcuts.left.shortcut1.tooltip" = "Google Chrome";
    "menus.dashboard.shortcuts.left.shortcut1.command" = "google-chrome-stable";
    "menus.dashboard.shortcuts.left.shortcut3.command" = "discord || vesktop";

    "theme.notification.enableShadow" = true;

    "menus.power.logout" = "uwsm stop";
    "menus.dashboard.powermenu.logout" = "uwsm stop";

    "theme.matugen_settings.scheme_type" = "expressive";

    "bar.volume.label" = false;
    "bar.volume.rightClick" = "pwvucontrol";
    "bar.launcher.autoDetectIcon" = true;

    "menus.clock.weather.key" = "/var/lib/hyprpanel_weatherapi_key";
    "menus.clock.weather.unit" = "metric";

    "bar.workspaces.show_icons" = false;
    "theme.bar.buttons.workspaces.enableBorder" = false;
    "bar.workspaces.show_numbered" = false;
    "bar.workspaces.workspaceMask" = false;
    "bar.workspaces.showWsIcons" = false;
    "bar.workspaces.showApplicationIcons" = false;

    "bar.notifications.hideCountWhenZero" = false;
    "theme.bar.border.location" = "none";
    "theme.bar.transparent" = true;

    "notifications.ignore" = [ "com.saivert.pwvucontrol" ];

    "bar.customModules.netstat.dynamicIcon" = false;
    "bar.customModules.netstat.label" = true;
    "bar.customModules.cava.leftClick" = "menu:media";
    "bar.windowtitle.leftClick" = "pkill rofi || true && ags -t 'overview'";

    "bar.customModules.worldclock.tz" = [
      "Asia/Kolkata"
      "America/New_York"
      "Europe/Paris"
      "Asia/Tokyo"
    ];
  };

  xdg.configFile."hyprpanel/modules.json".text = builtins.toJSON {
    # "custom/wl-logout" = {
    #   icon = " ⏻";
    #   label = "";
    #   executeOnAction = "wlogout";
    # };
  };
}
