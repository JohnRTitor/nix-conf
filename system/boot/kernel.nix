# This config file is used to configure the kernel
{ config, lib, pkgs, pkgs-stable, ... }:
{
  # Use linux-zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # zenpower is used for reading temperature, voltage, current and power
    # zenpower # disabled because k10temp is enough
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

        # POSIX Message Queues disabled - only needed in Solaris
        POSIX_MQUEUE = lib.mkForce unset;
        POSIX_MQUEUE_SYSCTL = lib.mkForce unset;

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
        X86_MPPARSE = unset; # MPS table is not needed for new systems with ACPI support

        # Disable intel specific services
        X86_MCE_INTEL = unset; # disable Intel MCE
        PERF_EVENTS_INTEL_UNCORE = unset; # disable intel UNCORE perf monitor
        PERF_EVENTS_INTEL_CSTATE = unset; # disable CSTATE intel

        X86_EXTENDED_PLATFORM = unset; # disable other X86 platforms
        
        # Enable AMD power monitors
        PERF_EVENTS_AMD_POWER = module; # load as a module
        PERF_EVENTS_AMD_BRS = yes;

        # Enable AMD SME
        DYNAMIC_PHYSICAL_MASK = yes; # for SME
        X86_MEM_ENCRYPT = yes;
        AMD_MEM_ENCRYPT = yes;
        AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT = unset;
        ARCH_HAS_CC_PLATFORM = yes;
        UNACCEPTED_MEMORY = yes;
        ARCH_HAS_FORCE_DMA_UNENCRYPTED = yes;
        DMA_COHERENT_POOL = yes;


        ##### MEMORY MANAGEMENT #####
        # Multigen LRU
        LRU_GEN = yes;
        LRU_GEN_ENABLED = yes;

        ##### DEVICE DRIVERS #####
        MACINTOSH_DRIVERS = no;

        # TODO: Disable a lot of unneeded drivers

        # Disable miscellaneous filesystem
        MISC_FILESYSTEMS = unset;
        # Disable kernel debugging
        DEBUG_KERNEL = lib.mkForce unset;
      };
    }
  ];
}