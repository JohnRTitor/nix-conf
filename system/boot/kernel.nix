# This config file is used to configure the kernel
{ config, lib, pkgs, pkgs-stable, ... }:
{
  # Use CachyOS LTO kernel for improved performance
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
  # Enable scx extra schedulers, only available for linux-cachyos
  chaotic.scx.enable = true; # by default uses rustland
  
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # zenpower is used for reading temperature, voltage, current and power
    zenpower
  ];

  # List of patches to compile the kernel with
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
      # Recompiling the kernel with optimization
      name = "AMD Patches";
      patch = null; # no patch is needed, just apply the options
      extraStructuredConfig = with lib.kernel; {
        # AMD native optimization
        X86_AMD_PLATFORM_DEVICE = yes;
        GENERIC_CPU = no;
        MNATIVE_AMD = yes;
        X86_USE_PPRO_CHECKSUM = yes;
        
        NR_CPUS = lib.mkForce (freeform "20"); # only 20 threads support
      };
    }
  ]
  # Available by default in cachyos
  ++ lib.optionals (config.boot.kernelPackages != pkgs.linuxPackages_cachyos) [
    {
      name = "ZSTD compression";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        # Kernel compression mode
        # Enable ZSTD and Disable GZIP
        KERNEL_GZIP = unset;
        KERNEL_ZSTD = yes;
        HAVE_KERNEL_ZSTD = yes;
      };
    }
    {
      name = "Performance options";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        # Kernel optimized for MORE performance
        CC_OPTIMIZE_FOR_PERFORMANCE = lib.mkForce unset;
        CC_OPTIMIZE_FOR_PERFORMANCE_O3 = lib.mkForce yes;
        # Enable performance power governor by default
        DEVFREQ_GOV_PERFORMANCE = lib.mkForce module;
        CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkForce yes;
        CPU_FREQ_GOV_PERFORMANCE = lib.mkForce yes;
      };
    }
    {
      name = "Multi-Gen LRU";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        # This option is used to improve the performance of the kernel
        # by using a multi-generation LRU algorithm to manage the page cache.

        LRU_GEN = yes;
        LRU_GEN_ENABLED = yes;
      };
    }
  ]
  # Add the NCT6775 driver, not available in xanmod, but available by default in cachyos
  # Option needed in linux-zen
  ++ lib.optionals (config.boot.kernelPackages != pkgs.linuxPackages_zen)  [
    {
      # recompiling the kernel with this option is needed for OpenRGB
      name = "NCT6775 driver";
      patch = null; # no patch needed if zen-kernel is enabled
      extraStructuredConfig = with lib.kernel; {
        I2C_NCT6775 = lib.mkForce module;
      };
    }
  ]
  ;
}