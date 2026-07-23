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

  (lib.mkIf (config.myOptions.programsSettings.displayManager == "gdm") {
    services.displayManager.gdm = {
      enable = true;
      banner = ''
                        Welcome Traveler, Behold!
        You are about to enter the realm of Hyprland
      '';
    };
  })

  # FUCK SDDM, BUGGY
  (lib.mkIf (config.myOptions.programsSettings.displayManager == "sddm") {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      theme = "golden-horizon";
      # wayland.enable = true;

      # Crucial for Qt6: Use the KDE/Qt6 build of SDDM to fix missing cursors and module errors
      package = pkgs.kdePackages.sddm;

      # Fix for NixOS explicitly requiring a cursor theme
      settings = {
        Theme = {
          CursorTheme = "breeze_cursors"; # Change this if you use a different cursor theme (e.g., Adwaita)
        };
      };

      # Required dependencies for Qt6 themes
      extraPackages = [
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtdeclarative
        pkgs.kdePackages.qt5compat
      ];
    };

    xdg.icons.fallbackCursorThemes = [ "breeze_cursors" ];

    environment.systemPackages = [
      pkgs.kdePackages.breeze

      (pkgs.stdenvNoCC.mkDerivation {
        name = "sddm-themes";
        src = pkgs.fetchFromGitHub {
          owner = "amitpadhan525";
          repo = "sddm-themes";
          rev = "main";
          hash = "sha256-HUCQY3qvziG+WQFXWcZ/dKwhdRpfNv8+Uzakjhf3YrY=";
        };
        installPhase = "
          mkdir -p $out/share/sddm/themes/golden-horizon
          cp -r themes/golden-horizon/* $out/share/sddm/themes/golden-horizon/
        ";
      })

      # # Install and customize the theme. All fields are optional and will
      # # fall back to theme defaults if not set.
      # (inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
      #   background = config.myOptions.systemSettings.stylixImage; # Nix path or absolute path
      #   # avatar = ./my-avatar.jpg; # Nix path or absolute path
      #   primaryColor = "#B3C8FF"; # Hex color code
      #   accentColor = "#3F5F91"; # Hex color code
      #   autoColor = true; # true/false
      #   backgroundColor = "#1A1C1E"; # Hex color code
      #   textColor = "#E2E2E6"; # Hex color code
      #   fontFamily = "JetBrains Mono"; # Font family name
      #   fontSize = 13; # Font size in px
      # })
    ];
  })
]
