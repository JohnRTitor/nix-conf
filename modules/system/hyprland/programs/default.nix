{ pkgs, self, ... }:
{
  imports = [
    ./file-manager.nix
  ];

  ## Configure essential packages ##

  environment.systemPackages =
    (with pkgs; [
      # Hyprland Stuff main
      cliphist # clipboard history
      grim # screenshots
      networkmanagerapplet
      nwg-look # theme switcher
      pamixer
      playerctl # media player control
      slurp # screenshots
      swappy # screenshots

      # swww # wallpaper daemon
      (writeShellScriptBin "swww" ''
        exec ${lib.getExe' awww "awww"} "$@"
      '')
      (writeShellScriptBin "swww-daemon" ''
        exec ${lib.getExe' awww "awww-daemon"} "$@"
      '')

      wallust # pywal alternative, graphical pallete generator
      wl-clipboard # clipboard manager
      wlogout # logout dialog
      yad

      gsettings-desktop-schemas
      wlr-randr # xrandr but for wayland
      ydotool

      ## Graphical apps ##

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
      xhost # needed for some packages running x11 like gparted

      ## GNOME Suite ##
      gnome-text-editor # text editor
      shotcut # video editor
      gnome-system-monitor # system monitor
      loupe # image viewer
      file-roller # archive manager
      evince # document viewer

      ## Hypr ecosystem ##
      hyprsunset # for night mode
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
      # self.packages.${pkgs.stdenv.hostPlatform.system}.weather-python-script # weather script'
    ];
}
