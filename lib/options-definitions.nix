{ lib, ... }:
{
  options.myOptions = {
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      systemarch = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "x86_64-linux";
        description = "System architecture";
      };
      hostname = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "NixOS";
        description = "Hostname";
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
        type = lib.types.enum [ "limine" "lanzaboote" "systemd-boot" ];
        default = "lanzaboote";
        description = "Bootloader to select, only lanzaboote has SecureBoot support for now";
      };
      laptop = lib.mkEnableOption "Laptop features";
    };

    # ----- USER SETTINGS ----- #
    userSettings = {
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

    servicesSettings = {
      adb = lib.mkEnableOption "ADB";
      avahi = lib.mkEnableOption "Avahi";
      nginx = lib.mkEnableOption "Nginx";
      containers = lib.mkEnableOption "Containers";
      tpm = lib.mkEnableOption "TPM";
      virtualisation = lib.mkEnableOption "Virtualisation";
      printing = lib.mkEnableOption "Printing";
      apparmor = lib.mkEnableOption "AppArmor";
    };

    programsSettings = {
      fileManager = lib.mkOption {
        type = lib.types.enum [
          "nautilus"
          "nemo"
        ];
        default = "nautilus";
        description = "File manager";
      };
    };
  };
}
