{
  self,
  config,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.myOptions.programsSettings.displayManager == "cosmic-greeter") {
    services.displayManager.cosmic-greeter.enable = true;

    environment.systemPackages = with pkgs; [
      cosmic-icons
    ];
  })

  (lib.mkIf (config.myOptions.programsSettings.displayManager == "sddm") {
    services.displayManager.sddm = {
      enable = true;
      theme = "pixie";
      wayland.enable = true;

      package = pkgs.kdePackages.sddm;

      # Required dependencies for Qt6 themes
      extraPackages = [
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtdeclarative
        pkgs.kdePackages.qt5compat
      ];
    };

    environment.systemPackages = [
      # Install and customize the theme. All fields are optional and will
      # fall back to theme defaults if not set.
      (inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
        background = config.myOptions.systemSettings.stylixImage; # Nix path or absolute path
        # avatar = ./my-avatar.jpg; # Nix path or absolute path
        primaryColor = "#B3C8FF"; # Hex color code
        accentColor = "#3F5F91"; # Hex color code
        autoColor = true; # true/false
        backgroundColor = "#1A1C1E"; # Hex color code
        textColor = "#E2E2E6"; # Hex color code
        fontFamily = "JetBrains Mono"; # Font family name
        fontSize = 13; # Font size in px
      })
    ];
  })
]
