# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{
  self,
  config,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}: let
  hyprlandFlake = true;
  hyprlandLTO = true;
  pkgs-hyprland =
    if hyprlandFlake
    then inputs.hyprland.packages.${pkgs.system}
    else pkgs;
in {
  imports = [
    ./session.nix
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    package =
      (pkgs-hyprland.hyprland.override {
        stdenv = pkgs.clangStdenv;
      })
      .overrideAttrs
      (prevAttrs: {
        patches =
          (prevAttrs.patches or [])
          ++ [
            ./add-env-vars-to-export.patch
          ]
          ++ lib.optionals hyprlandLTO [
            ./enable-lto.patch
          ];
        mesonFlags =
          prevAttrs.mesonFlags
          or []
          ++ lib.optionals hyprlandLTO [
            (lib.mesonBool "b_lto" true)
            (lib.mesonOption "b_lto_threads" "12")
            (lib.mesonOption "b_lto_mode" "thin")
            (lib.mesonBool "b_thinlto_cache" true)
          ];
      });
    portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
  };

  # hyprland portal is already included, gtk is also needed for compatibility
  xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

  ## QT theming ##
  qt = {
    enable = true;
    style = "kvantum";
    platformTheme = "qt5ct";
  };

  ## Configure essential programs ##

  programs.waybar = {
    enable = true; # enable waybar launcher
    package = pkgs.waybar;
  };
  systemd.user.services.waybar.environment = {
    PATH = lib.mkForce "/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  };

  programs.hyprlock = {
    enable = true; # enable Hyprlock screen locker
    package = pkgs.hyprlock;
  };

  services.hypridle = {
    enable = true; # enable Hypridle idle manager, needed for Hyprlock
    package = pkgs.hypridle;
  };

  programs = {
    evince.enable = true; # document viewer
    file-roller.enable = true; # archive manager
  };

  services.gnome = {
    sushi.enable = true; # quick previewer for nautilus
    glib-networking.enable = true; # network extensions libs
  };

  services.tumbler.enable = true; # thumbnailer service for nauitlus
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

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
      # POLKIT service is manually started
      # as defined in Hyprland-Dots repo
      rofi-wayland # app launcher
      slurp # screenshots
      swappy # screenshots
      swaynotificationcenter # notification daemon
      swww # wallpaper daemon
      wallust # pywal alternative, graphical pallete generator
      wlsunset # for night mode
      wl-clipboard # clipboard manager
      wlogout # logout dialog
      yad

      gsettings-desktop-schemas
      wlr-randr # xrandr but for wayland
      ydotool

      ## Graphical apps ##

      kitty # default terminal on hyprland
      linux-wifi-hotspot # for wifi hotspot
      (mpv-unwrapped.override {
        # mpv with more features
        jackaudioSupport = true;
        vapoursynthSupport = true;
      }) # for video playback, needed for some scripts
      mpvScripts.mpris

      ## Utilities ##
      desktop-file-utils
      shared-mime-info
      xdg-utils
      xdg-user-dirs
      xorg.xhost # needed for some packages running x11 like gparted

      ## GNOME Suite ##
      nautilus # file manager
      gnome-text-editor # text editor
      shotcut # video editor
      gnome-system-monitor # system monitor
      loupe # image viewer

      ## Hypr ecosystem ##
      hyprcursor
      rose-pine-hyprcursor # cursor theme
      pyprland # hyprland plugin, dropdown term, etc
      ags_1 # widgets popup

      ## MONITORING TOOLS ##
      btop # for CPU, RAM, and Disk monitoring
      nvtopPackages.amd # for AMD GPUs
    ])
    ++ [
      self.packages.${pkgs.system}.weather-python-script # weather script'
    ];

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent, GUI Polkit agent for Hyprland";

    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    script = lib.getExe pkgs.hyprpolkitagent;
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

    NIXOS_OZONE_WL = "1"; # for electron and chromium apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1"; # firefox should always run on wayland

    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui
  };
}
