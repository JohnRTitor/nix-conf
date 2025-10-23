{
  config,
  lib,
  pkgs,
  programsSettings,
  ...
}:
lib.mkMerge [
  (lib.mkIf (programsSettings.fileManager == "nautilus") {
    environment.systemPackages = with pkgs; [
      nautilus
    ];
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };
    services.gnome.sushi.enable = true; # quick previewer for nautilus
  })

  (lib.mkIf (programsSettings.fileManager == "nemo") {
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

  # Common services
  {
    services.tumbler.enable = true; # thumbnailer service for nauitlus
  }
]
