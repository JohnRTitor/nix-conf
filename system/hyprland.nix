# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{ pkgs, pkgs-stable, ... }:

let
  python-packages = pkgs.python3.withPackages (ps: [
    ps.requests # requests module
    ps.sh # subprocess module
    ps.pyquery
  ]);
in
{
  # Enable Hyprland Window Manager
  programs.hyprland.enable = true;
  programs.waybar.enable = true; # enable waybar launcher
  # Enable GDM with wayland
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # hyprland portal is already included, gtk is also needed for compatibility
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  ## QT theming ##
  qt.enable = true;
  qt.style = "kvantum";
  qt.platformTheme = "qt5ct";

  ## Configure essential programs ##

  programs = {
    evince.enable = true; # document viewer
    file-roller.enable = true; # archive manager
    # Xfce file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo
        mousepad # text editor
        thunar-archive-plugin # archive manager
        thunar-volman
      ];
    };
  };

  services.gnome = {
    sushi.enable = true; # quick previewer for nautilus
    glib-networking.enable = true; # network extensions libs
  };
  services.tumbler.enable = true; # thumbnailer service

  ## Configure essential packages ##

  environment.systemPackages =
    (with pkgs; [
          
      # Hyprland Stuff main
      cava # audio visualizer
      cliphist # clipboard history
      grim # screenshots
      jq # json parser
      networkmanagerapplet
      nwg-look # theme switcher
      openssl # required by Rainbow borders
      pamixer 
      pavucontrol # audio control
      playerctl # media player control
      polkit_gnome # needed for apps requesting root access
      pyprland # hyprland plugin support
      python-packages # needed for Weather.py from dotfiles
      pywal
      rofi-wayland 
      slurp # screenshots
      swappy # screenshots
      swayidle
      swaylock-effects
      swaynotificationcenter
      swww
      wlsunset # for night mode
      wl-clipboard
      wlogout
      yad

      gsettings-desktop-schemas
      wlr-randr
      ydotool
      hyprland-protocols
      # hyprpicker # does not work
      # hyprpaper # alternative to swww

      ## Graphical apps ##
      gnome.gnome-system-monitor # system monitor
      gnome.eog # eye of gnome, image viewer
      gnome.gnome-music # audio player
      kitty # default terminal on hyprland
      linux-wifi-hotspot # for wifi hotspot
      mpv-vapoursynth # mpv # for video playback, needed for some scripts
      mpvScripts.mpris
      gnome.nautilus # file manager
      shotcut # video editor
      
      ## QT theming and apps support ##
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland

      ## Utilities ##
      desktop-file-utils
      shared-mime-info
      xdg-utils
      xdg-user-dirs
      xorg.xhost # needed for some packages running x11 like gparted
    ])

    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      # Can be used to downgrade packages
      
    ]);

  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    # WLR_NO_HARDWARE_CURSORS = "1"; # cursor not visible, needed for nvidia

    NIXOS_OZONE_WL = "1"; # for electron and chromium apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1"; # firefox should always run on wayland
    
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1"; # On tiling window managers like hyprland this is needed for java apps
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11"; # GTK: use wayland if possible, else X11
    QT_QPA_PLATFORM = "wayland;xcb"; # QT: use wayland if possible, else X11
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui

    # WLR_RENDERER = "vulkan"; # vulkan not supported in hyprland
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
  # Text for swaylock
  security.pam.services.swaylock.text = "auth include login";
}