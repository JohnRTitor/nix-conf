# Configure graphics and hardware acceleration settings etc.
{
  config,
  lib,
  pkgs,
  pkgs-master,
  ...
}:
let
  nur-amdgpu = pkgs.nur.repos.materus;

  ## PREFS ##
  enablePRODrivers = false;
  enableOpenCL = true;
  # Enabling AMDVLK autodisables Mesa Radv
  enableAMDVLK = false;
  enableOverclocking = true;
in
lib.mkMerge [
  {
    hardware.amdgpu.initrd.enable = true; # Load AMDGPU kernel driver at initrd stage 1

    # Enable OpenGL and Vulkan support
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # LIBVA and VDPAU are hardware acceleration drivers
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      # For 32 bit applications
      extraPackages32 = with pkgs.driversi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    # XORG driver - amdgpu is deprecated, modesetting is maintained
    # and works for both AMDGPU and NVIDIA
    services.xserver.videoDrivers = [ "modesetting" ];

    ### Graphics environment variables ###

    # apparently no need to set libva driver name explicitly anymore
    # environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

    # best for amdgpu, va_gl can be used to select vaapi backend for vdpau,
    # but it does not support a lot of features
    # we need to set this manually like below for HW video decoding to work
    environment.sessionVariables.VDPAU_DRIVER = "radeonsi";

    environment.systemPackages = with pkgs; [
      ## GRAPHICS UTILS ##
      /*
        NOT NEEDED UNLESS WE NEED TO DO TESTING
        clinfo # OpenCL hardware information
        libva-utils # libva graphics library tools
        vdpauinfo # vdpau graphics library tools
        vulkan-tools # vulkan graphics library tools
      */
    ];
  }

  ### OpenCL backends - Pocl for CPU, ROCM for iGPU and discrete GPU
  (lib.mkIf enableOpenCL {
    hardware.amdgpu.opencl.enable = false;
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL for AMD GPUs
      pocl # OpenCL for CPU
    ];
  })

  (lib.mkIf enableOverclocking {
    # Enable driver support for AMD GPU overclocking
    hardware.amdgpu.overdrive = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };

    # Overclocking software
    services.lact.enable = true;
  })

  (lib.mkIf enablePRODrivers {
    # AMDGPU-PRO firmware
    hardware.firmware = with nur-amdgpu; [
      amdgpu-pro-libs.firmware.vcn
      amdgpu-pro-libs.firmware
    ];

    environment.systemPackages = with nur-amdgpu; [
      amdgpu-pro-libs.prefixes
    ];

    hardware.graphics.extraPackages = with nur-amdgpu; [
      amdgpu-pro-libs.opengl
      amdgpu-pro-libs.vulkan
      amdgpu-pro-libs.amf
    ];
  })

  ### Alternate Vulkan driver - AMDVLK ###
  (lib.mkIf enableAMDVLK {
    # AMDVLK is buggy and VK implementation is not good
    # RADV is better
    hardware.amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
      supportExperimental.enable = true;
      settings = {
        AllowVkPipelineCachingToDisk = 1;
        ShaderCacheMode = 1;
        IFH = 0;
        EnableVmAlwaysValid = 1;
        IdleAfterSubmitGpuMask = 0;
      };
    };
  })
]
