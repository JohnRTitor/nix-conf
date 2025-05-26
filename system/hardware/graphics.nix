# Configure graphics and hardware acceleration settings etc.
{
  config,
  pkgs,
  pkgs-master,
  ...
}:
let
  nur-amdgpu = pkgs.nur.repos.materus;
in
{
  hardware.amdgpu = {
    initrd.enable = true;
    # disabled to use a mix of pocl and rocm below
    opencl.enable = false;
  };

  /*
    # Enabling AMDVLK autodisables RADV
    # RADV is better
    # AMDVLK is buggy and VK implementation is not good
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
  */

  # AMDGPU-PRO firmware
  hardware.firmware = with nur-amdgpu; [
    amdgpu-pro-libs.firmware.vcn
    amdgpu-pro-libs.firmware
  ];

  # Enable OpenGL and Vulkan support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # Extra drivers
    extraPackages =
      (with pkgs; [
        # LIBVA and VDPAU are hardware acceleration drivers
        libva-vdpau-driver
        libvdpau-va-gl
        libva
        rocmPackages.clr.icd # OpenCL for AMD GPUs
        pocl # OpenCL for CPU
      ])
      ++ (with nur-amdgpu; [
        amdgpu-pro-libs.opengl
        amdgpu-pro-libs.vulkan
        amdgpu-pro-libs.amf
      ]);
    # For 32 bit applications
    extraPackages32 = with pkgs.driversi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  environment.systemPackages =
    (with pkgs; [
      ## GRAPHICS UTILS ##
      /*
           NOT NEEDED UNLESS WE NEED TESTING
        clinfo # OpenCL hardware information
        libva-utils # libva graphics library tools
        vdpauinfo # vdpau graphics library tools
        vulkan-tools # vulkan graphics library tools
      */
    ])
    ++ (with nur-amdgpu; [
      amdgpu-pro-libs.prefixes
    ]);

  # Use modesetting driver for Xorg, its better and updated
  # AMDGPU graphics driver for Xorg is deprecated
  services.xserver.videoDrivers = [ "modesetting" ];

  # Graphics environment variables
  environment.sessionVariables = {
    # apparently no need to set libva driver name anymore
    # LIBVA_DRIVER_NAME = "radeonsi";
    # best for amdgpu, va_gl can be used to select vaapi backend for vdpau,
    # but it does not support a lot of features
    # we need to set this manually like below
    VDPAU_DRIVER = "radeonsi";
  };

  services.lact.enable = true;

  hardware.amdgpu.overdrive = {
    enable = true;
    ppfeaturemask = "0xffffffff";
  };
}
