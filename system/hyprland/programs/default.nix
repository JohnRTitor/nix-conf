{ pkgs, self, ... }:
{
  imports = [
    ./file-manager.nix
  ];

  ## Configure essential programs ##

  programs.evince.enable = true; # document viewer
  programs.file-roller.enable = true; # archive manager

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
      pwvucontrol # audio control
      playerctl # media player control
      rofi # app launcher
      slurp # screenshots
      swappy # screenshots
      swaynotificationcenter # notification daemon
      swww # wallpaper daemon
      wallust # pywal alternative, graphical pallete generator
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
      gnome-text-editor # text editor
      shotcut # video editor
      gnome-system-monitor # system monitor
      loupe # image viewer

      ## Hypr ecosystem ##
      hyprcursor
      hyprsunset # for night mode
      rose-pine-hyprcursor # cursor theme
      ags_1 # widgets popup
      pyprland # hyprland plugin, dropdown term, etc

      ## MONITORING TOOLS ##
      btop-rocm # for CPU, RAM, and Disk monitoring
      nvtopPackages.amd # for AMD GPUs

      ## NEEDED FOR Hyprland-Dots ##
      bc
      pciutils
    ])
    ++ [
      self.packages.${pkgs.hostPlatform.system}.weather-python-script # weather script'
    ];
}
