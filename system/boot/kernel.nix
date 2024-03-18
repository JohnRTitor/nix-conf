# This config file is used to configure the kernel
{ config, lib, pkgs, pkgs-stable, ... }:
{
  # Use linux-zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
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
      extraStructuredConfig = with lib.kernel; {

        ##### GENERAL OPTIONS #####
        
        # Kernel compression mode
        # Enable ZSTD and Disable GZIP
        KERNEL_GZIP = unset;
        KERNEL_ZSTD = yes;

        # Kernel optimized for MORE performance
        CC_OPTIMIZE_FOR_PERFORMANCE = unset;
        CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;

        ##### CPU OPTIONS #####

        # AMD native optimization
        X86_AMD_PLATFORM_DEVICE = yes;
        GENERIC_CPU = unset;
        MNATIVE_AMD = yes;
        X86_USE_PPRO_CHECKSUM = yes;
        
        NR_CPUS = lib.mkForce (freeform "20"); # only 20 threads support

        ##### MEMORY MANAGEMENT #####
        # Multigen LRU
        LRU_GEN = yes;
        LRU_GEN_ENABLED = yes;
      };
    }
  ];
}