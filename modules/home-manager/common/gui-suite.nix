{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    home.packages = with pkgs; [
      ## Graphical apps ##
      linux-wifi-hotspot # for wifi hotspot
      pwvucontrol # audio control

      baobab # disk usage analyzer
      gnome-text-editor # text editor

      gnome-disk-utility # disk partition editor
    ];

    dbus.packages = with pkgs; [
      gnome-disk-utility
    ];
  }

  ## GNOME Graphical Suite ##
  (lib.mkIf (config.myOptions.programsSettings.guiSuite == "gnome") {
    home.packages = with pkgs; [
      # shotcut # video editor
      gnome-system-monitor # system monitor
      loupe # image viewer
      file-roller # archive manager
      evince # document viewer
    ];
  })

  ## KDE Graphical Suite ##
  (lib.mkIf (config.myOptions.programsSettings.guiSuite == "kde") {
    home.packages = with pkgs.kdePackages; [
      gwenview # image viewer
      okular # document viewer (PDF, EPUB, comics, etc.)
      ark # archive manager
      kleopatra # certificate and key manager

      # ksystemlog # system log viewer
      # kwalletmanager # password and secrets manager
      # elisa # music player
      # kdeconnect-kde # device integration with Android and other computers

      # partitionmanager # disk partition editor
      # partitionmanager.kpmcore # needed for polkit prompts
    ];

    # needed for polkit prompts
    # dbus.packages = with pkgs.kdePackages; [ partitionmanager.kpmcore ];

    qt.kde.settings = {
      dolphinrc.UiSettings.ColorScheme = "*";
      arkrc.UiSettings.ColorScheme = "*";
      okularrc.UiSettings.ColorScheme = "*";

      # Easily uncomment these later if needed:
      # kwriterc.UiSettings.ColorScheme = "*";
      # katerc.UiSettings.ColorScheme = "*";
      # konsolerc.UiSettings.ColorScheme = "*";
      # kcalcrc.UiSettings.ColorScheme = "*";
      # ktimerrc.UiSettings.ColorScheme = "*";
      # kalarmrc.UiSettings.ColorScheme = "*";
    };
  })
]
