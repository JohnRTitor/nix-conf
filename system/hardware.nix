# Configure hardware - graphics, sound, etc.
{ config, pkgs, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true; # Mesa
    driSupport = true; # Vulkan
    driSupport32Bit = true;
    # Extra drivers
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
      vaapiVdpau
      libvdpau-va-gl
    ];
    # For 32 bit applications 
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
      libva
    ];
  };

  # AMDGPU graphics driver - disabled in favor of modesetting driver
  services.xserver.videoDrivers = [ "amdgpu-pro" ];
  
  # Graphics environment variables
  environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
    __GLX_VENDOR_LIBRARY_NAME = "amdgpu";
  };

  # Enable zram swap
  zramSwap.enable = true;
  # Enable scrubbing for btrfs - by default once a month
  services.btrfs.autoScrub.enable = true;
  # Disable last access time to increase performance
  fileSystems = {
    "/".options = [ "noatime" ];
  };

  # fstrim for SSD
  services.fstrim = {
    enable = true;
    interval = "monthly";
  };

}