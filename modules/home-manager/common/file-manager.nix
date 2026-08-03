{
  self,
  config,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.myOptions.programsSettings.fileManager == "dolphin") {
    home.packages = with pkgs; [
      kdePackages.dolphin
    ];

    qt.kde.settings = {
      kdeglobals = {
        "General" = {
          # Set the default terminal for Dolphin
          "TerminalApplication" = config.myOptions.programsSettings.terminal;
          "TerminalService" = "${config.myOptions.programsSettings.terminal}.desktop";
        };
      };
    };

    # Needed by kbuildsycoca6
    xdg.configFile."menus/applications.menu".source = "${
      self.packages.${pkgs.stdenv.hostPlatform.system}.plasma-xdg-menu
    }/etc/xdg/menus/plasma-applications.menu";

    systemd.user.services.kbuildsycoca6 = {
      Unit = {
        Description = "Regenerate KDE service cache";
        After = [ "hyprland-session.target" ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "oneshot";
        # UWSM sets XDG_MENU_PREFIX=hyprland- by default, but kbuildsycoca6
        # needs plasma- to find the KDE application menu database.
        Environment = "XDG_MENU_PREFIX=plasma-";
        ExecStart = "${pkgs.kdePackages.kservice}/bin/kbuildsycoca6";
      };
    };

    systemd.user.paths.kbuildsycoca6 = {
      Unit = {
        Description = "Watch for application changes";
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
      Path = {
        PathChanged = [
          "/run/current-system"
          "%h/.nix-profile"
        ];
      };
    };
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "nautilus") {
    home.packages = with pkgs; [
      nautilus
      sushi # quick previewer for nautilus
      nautilus-open-any-terminal
    ];

    dconf.settings = {
      "com/github/stunkymonkey/nautilus-open-any-terminal" = {
        terminal = config.myOptions.programsSettings.terminal;
      };
    };
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "nemo") {
    home.packages = with pkgs; [
      (nemo-with-extensions.override {
        extensions = with pkgs; [
          nemo-seahorse
          nemo-qml-plugin-dbus
        ];
      })
    ];

    home.file.".local/share/nemo/actions/open_in_kitty.nemo_action".source =
      ./open_in_kitty.nemo_action;
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "thunar") {
    home.packages = with pkgs; [
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      ffmpegthumbnailer # Need For Video / Image Preview
    ];

    home.file.".config/xfce4/helpers.rc".text = ''
      WebBrowser=google-chrome-stable
      Editor=code
      TerminalEmulator=${config.myOptions.programsSettings.terminal}
      TerminalEmulatorDismissed=true
    '';
  })

  # Common packages
  {
    # home.packages = with pkgs; [
    #   tumbler # thumbnailer service
    # ];
  }
]
