{
  config,
  lib,
  pkgs,
  programsSettings,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.myOptions.programsSettings.fileManager == "dolphin") {
    environment.systemPackages = with pkgs; [
      kdePackages.dolphin
    ];
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "nautilus") {
    environment.systemPackages = with pkgs; [
      nautilus
    ];

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = config.myOptions.programsSettings.terminal;
    };

    services.gnome.sushi.enable = true; # quick previewer for nautilus
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "nemo") {
    environment.systemPackages = with pkgs; [
      (nemo-with-extensions.override {
        extensions = with pkgs; [
          nemo-seahorse
          nemo-qml-plugin-dbus
          # + default extensions: https://github.com/NixOS/nixpkgs/blob/360e0a6013f94d32ea86050d3646e3ccba1c2667/pkgs/by-name/ne/nemo-with-extensions/package.nix#L18
        ];
      })
    ];

    environment.pathsToLink = [
      "/share/nemo"
    ];
  })

  (lib.mkIf (config.myOptions.programsSettings.fileManager == "thunar") {
    programs.thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    };

    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer # Need For Video / Image Preview
    ];
  })

  # Common services
  {
    services.tumbler.enable = true; # thumbnailer service for nauitlus
  }
]
