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
      networkmanagerapplet
      nwg-look # theme switcher
      pamixer
      playerctl # media player control

      ## Graphical apps ##
      linux-wifi-hotspot # for wifi hotspot

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

      ## MONITORING TOOLS ##
      nvtopPackages.amd # for AMD GPUs
    ])
    ++ [
      # self.packages.${pkgs.stdenv.hostPlatform.system}.weather-python-script # weather script'
    ];
}
