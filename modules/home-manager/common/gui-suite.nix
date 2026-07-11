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

    systemd.user.services.fix-kde-color-schemes =
      let
        kwriteconfig = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
        # TODO: ksystemlog, kalarm
        rcFiles = [
          "dolphinrc"
          # "kwriterc"
          # "katerc"
          # "konsolerc"
          "arkrc"
          "okularrc"
          # "kcalcrc"
          # "ktimerrc"
          # "kalarmrc"
        ];
      in
      {
        Unit = {
          Description = "Force ColorScheme in KDE apps.";
          After = [
            "hyprland-session.target"
          ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "fix-kde-color-schemes" ''
            set -eu
            for f in ${builtins.concatStringsSep " " rcFiles}; do
              ${kwriteconfig} --file "$f" --group UiSettings --key ColorScheme '*'
            done
          '';
        };

        Install = {
          WantedBy = [
            "hyprland-session.target"
          ];
        };
      };
  })
]
