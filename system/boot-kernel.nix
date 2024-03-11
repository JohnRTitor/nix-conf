# This conf file is used to configure boot 
{ config, pkgs, lib, systemSettings, ... }:

{
  imports = if (systemSettings.secureboot == true) then [ ./boot/lanzaboote.nix ] else [ ./boot/systemd-boot.nix ];
  # Bootspec needed for secureboot
  boot.bootspec.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # bootloader timeout set, also press t repeatedly in the bootmenu to set there
  boot.loader.timeout = 15;
  # start systemd early
  # boot.initrd.systemd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # zenpower is used for reading temperature, voltage, current and power
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower
  ];

  boot.kernelPatches = [
    # Kernel lockdown patch
    # {
    #   name = "kernel-lockdown";
    #   patch = null;
    #   extraStructuredConfig = with lib.kernel; {
    #     SECURITY_LOCKDOWN_LSM = lib.mkForce yes;
    #     MODULE_SIG = lib.mkForce yes;
    #   };
    # }
    {
      # recompiling the kernel with this option is needed for OpenRGB
      name = "NCT6775 driver";
      patch = null; # no patch needed if zen-kernel is enabled
      extraStructuredConfig = with lib.kernel; {
        I2C_NCT6775 = lib.mkForce yes;
      };
    }
    {
      # Recompiling the kernel with optimization
      name = "AMD Patches";
      patch = null; # no patch is needed, just apply the options
      # enable only support for upto 20 CPU threads in the kernel
      extraConfig = ''
        NR_CPUS 20
      '';
      extraStructuredConfig = with lib.kernel; {
        # enable compiler optimizations for AMD
        MNATIVE_AMD = lib.mkForce yes;
        X86_USE_PPRO_CHECKSUM = lib.mkForce yes;

        X86_EXTENDED_PLATFORM = lib.mkForce no; # disable support for other x86 platforms

        X86_MCE_INTEL = lib.mkForce no; # disable support for intel mce

        # Optimized for performance
        CC_OPTIMIZE_FOR_PERFORMANCE_O3 = lib.mkForce yes;

        # Multigen LRU
        LRU_GEN = lib.mkForce yes;
        LRU_GEN_ENABLED = lib.mkForce yes;
      };
    }
  ];

  # Also load amdgpu at boot
  boot.kernelModules = [ "amdgpu" ];
  # boot.consoleLogLevel = 0; # configure silent boot
  boot.kernelParams = [
    # "acpi_enforce_resources=lax" # openrgb
    # "quiet"
    # "udev.log_level=3"
    # "lockdown=integrity"
  ];

  # plymouth theme for splash screen
  boot.plymouth = rec {
    enable = true;
    # black_hud circle_hud cross_hud square_hud
    # circuit connect cuts_alt seal_2 seal_3
    theme = "connect";
    themePackages = with pkgs; [(
      adi1090x-plymouth-themes.override {
        selected_themes = [ theme ];
      }
    )];
  };
}
