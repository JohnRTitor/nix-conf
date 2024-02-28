# Configure hardware - graphics, sound, etc.
{ config, ... }:

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
  # services.xserver.videoDrivers = ["amdgpu"];

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

  # Enable sound with pipewire.
  sound.enable = true;
  # disable pulseaudio, infavor of pipewire
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

}