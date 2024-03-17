# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{ pkgs, pkgs-stable, ... }:

{
    imports =
    [ # Include GNOME Keyring settings
      ./gnome-keyring.nix
    ];
  programs = {
    # Enable Hyperland
    hyprland.enable = true;
    waybar.enable = true; # enable waybar launcher
    # Xfce file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo
        mousepad # texr editor
        thunar-archive-plugin # archive manager
        thunar-volman
        tumbler # thumbnailer service
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
      glib-networking.enable = true; # network extensions libs
    };

    tumbler.enable = true; # thumbnailer service
  };

  environment.systemPackages =
    (with pkgs; [
          
      # Hyprland Stuff main
      # blueman # not needed if blueman service is on
      cava # audio visualizer
      cliphist # clipboard history
      gnome.file-roller # archive manager
      gnome.gnome-system-monitor # system monitor
      gnome.eog # eye of gnome, image viewer
      grim # screenshots
      jq # json parser
      kitty # default terminal on hyprland
      networkmanagerapplet
      nwg-look # theme switcher
      openssl # required by Rainbow borders
      pamixer 
      pavucontrol # audio control
      playerctl # media player control
      polkit_gnome # needed for apps requesting root access
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
      wlsunset # for night mode
      wl-clipboard
      wlogout
      xdg-utils
      # xdg-desktop-portal-hyprland - included by default for hyprland.enable
      xdg-user-dirs
      xorg.xhost # needed for some packages running x11 like gparted
      yad

      # Utilities
      gnome.gnome-music # audio player
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
      
      # for opening files in correct apps
      shared-mime-info
      desktop-file-utils
      
    ])

    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      
    ]);


  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    WLR_NO_HARDWARE_CURSORS = "1"; # cursor not visible in some instance
    NIXOS_OZONE_WL = "1"; # for electron apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11"; # GTK: use wayland if possible, else X11
    QT_QPA_PLATFORM = "wayland;xcb"; # QT: use QT if possible, else X11
    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui
  };

  systemd = {
    # Fix opening links in apps like vscode
    user.extraConfig = ''
      DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:/var/lib/flatpak/exports/bin:/nix/profile/bin:/etc/profiles/per-user/masum/bin:/nix/var/nix/profiles/default/bin:/home/masum/.local/share/applications/"
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