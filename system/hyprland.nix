# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{ pkgs, pkgs-unstable, ... }:

{
  programs = {
    # Enable Hyperland
    hyprland.enable = true;
    waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
    # Xfce file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo
        mousepad
        thunar-archive-plugin
        thunar-volman
        tumbler
      ];
    };

    dconf.enable = true;
    partition-manager.enable = true; # KDE Partition Manager
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      excludePackages = [ pkgs.xterm ];
      libinput.enable = true;
      # Enable GDM
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    accounts-daemon.enable = true;
    dbus.enable = true;
    udev.enable = true; 
    gnome = {
      sushi.enable = true; # quick previewer
      gnome-keyring.enable = true; # apps like vscode stores encrypted data using it
      glib-networking.enable = true; # network extensions libs
    };

    tumbler.enable = true; # thumbnailer service
  };

  environment.systemPackages =
    (with pkgs; [
          
      # Hyprland Stuff main
      # blueman # not needed if blueman service is on
      btop
      cava
      cliphist
      gnome.file-roller
      gnome.gnome-system-monitor
      gnome.eog # eye of gnome
      grim
      jq
      kitty # default terminal on hyprland
      libsecret # needed for gnome-keyring
      networkmanagerapplet
      nwg-look
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pyprland # hyprland plugin support
      pywal
      rofi-wayland
      slurp # screenshots
      swappy # screenshots
      swayidle
      swaylock-effects
      swaynotificationcenter
      swww
      # Can control theming on QT apps
      # QT Wayland
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      # Kvantum
      qt6Packages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      # QT control center
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      # waybar # included by default for hyprland.waybar.enable
      wl-clipboard
      wlogout
      xdg-utils
      # xdg-desktop-portal-hyprland - included by default for hyprland.enable
      xdg-user-dirs
      xorg.xhost # needed for some packages running x11 like gparted
      yad

      # Utilities
      audacious # audio player
      mpv # for video playback, needed for some scripts
      mpvScripts.mpris
      shotcut # video editor

      gsettings-desktop-schemas
      wlr-randr
      ydotool
      hyprland-protocols
      # hyprpicker # does not work
      # hyprpaper # alternative to swww
      # wofi # alternative to rofi-wayland
      grim # screenshots
      # for opening files in correct apps
      shared-mime-info
      desktop-file-utils
      
    ])

    ++

    (with pkgs-unstable; [
      # list of latest packages from unstable repo
      
    ]);


  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    WLR_NO_HARDWARE_CURSORS = "1"; # if your cursor is not visible
    NIXOS_OZONE_WL = "1"; # for electron apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui
  };

  systemd = {
    # Fix opening links in apps like vscode
    user.extraConfig = ''
      DefaultEnvironment="PATH=/run/current-system/sw/bin"
    '';
      # Polkit starting systemd service - needed for apps requesting root access
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}