{ lib, ... }:
{
  options.myOptions = {
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      systemarch = lib.mkOption {
        type = lib.types.enum [
          "x86_64-linux"
          "aarch64-linux"
        ];
        default = "x86_64-linux";
        description = "System architecture";
      };
      timezone = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "America/New_York";
        description = "Timezone";
      };
      locale = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "en_US.UTF-8";
        description = "Locale";
      };
      additionalLocale = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "en_IN";
        description = "Additonal Locale";
      };
      stableversion = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "24.11";
        description = "Stable version (DO NOT CHANGE)";
      };
      bootloader = lib.mkOption {
        type = lib.types.enum [
          "limine"
          "lanzaboote"
          "systemd-boot"
        ];
        default = "lanzaboote";
        description = "Bootloader to select, only lanzaboote and limine have SecureBoot support for now";
      };
      laptop = lib.mkEnableOption "Laptop features";
      tpm = lib.mkEnableOption "TPM control and features";
    };

    # ----- USER SETTINGS ----- #
    userSettings = lib.mkOption {
      description = "User specific configuration";
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              username = lib.mkOption {
                type = lib.types.singleLineStr;
                default = "alice";
                description = "Username";
              };
              name = lib.mkOption {
                type = lib.types.singleLineStr;
                default = "Alice";
                description = "Name/Identifier";
              };
              gitname = lib.mkOption {
                type = lib.types.singleLineStr;
                default = "Alice";
                description = "Name used for Git operations";
              };
              gitemail = lib.mkOption {
                type = lib.types.singleLineStr;
                default = "example@example.com";
                description = "Email used for Git operations";
              };
              gpgkey = lib.mkOption {
                type = lib.types.singleLineStr;
                description = "GPG key ID for Git operations";
              };
              shell = lib.mkOption {
                type = lib.types.enum [
                  "zsh"
                  "bash"
                ];
                default = "zsh";
                description = "User default shell";
              };
            };
          }
        )
      );
      example = "";
    };

    servicesSettings = {
      avahi = lib.mkEnableOption "Avahi";
      containers = lib.mkEnableOption "Containers";
      tpm = lib.mkEnableOption "TPM";
      virtualisation = lib.mkEnableOption "Virtualisation";
      printing = lib.mkEnableOption "Printing";
      apparmor = lib.mkEnableOption "AppArmor";
    };

    devSettings = {
      adb = lib.mkEnableOption "ADB";
      nginx = lib.mkEnableOption "Nginx";
      mysql = lib.mkEnableOption "MySQL";
      postgresql = lib.mkEnableOption "PostgreSQL";
      jupyter = lib.mkEnableOption "Jupyter";
    };

    programsSettings = {
      fileManager = lib.mkOption {
        type = lib.types.enum [
          "nautilus"
          "nemo"
          "thunar"
        ];
        default = "nautilus";
        description = "File manager";
      };

      terminal = lib.mkOption {
        type = lib.types.enum [
          "kitty"
          "alacritty"
        ];
        default = "kitty";
        description = "Terminal emulator";
      };

      statusbar = lib.mkOption {
        type = lib.types.enum [
          "waybar"
          "noctalia"
          "hyprpanel"
        ];
        default = "noctalia";
        description = "Status bar";
      };

      openrgb = lib.mkEnableOption "OpenRGB";
    };
  };
}
