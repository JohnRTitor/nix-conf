# Configure disks and zram
{
  config,
  pkgs,
  pkgs-master,
  ...
}:
{
  fileSystems = {
    "/".options = [
      "defaults"
      "noatime"
      # "version_upgrade=incompatible" # set this to forcefully upgrade the version
    ]; # disable access time updates
  };

  boot.bcachefs.package = pkgs-master.bcachefs-tools;
  services.bcachefs.autoScrub.enable = true;
  boot.kernel.sysfs.fs.bcachefs.dm-0.dev-0.label = "NixOS-Root";

  # Enable ZRAM
  zramSwap = {
    enable = true;
    # this means that maximum 200% worth of physical memory size
    # can be utilised in zram, by using compression
    # this does not mean 200% of actual physical memory is used
    memoryPercent = 100;
  };

  # Enable ZSwap
  boot.kernel.sysfs.module.zswap.parameters.enabled = 1;

  /*
       SWAP DELETED
    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/90c8cb42-7424-467c-927a-0d6a63d5b2a2";
        options = [
          "defaults"
          "nofail"
        ];
        randomEncryption = {
          enable = true;
          keySize = 512;
        };
      } # 16 Gigs swap
    ];
  */

  boot.kernel.sysctl = {
    # Setting High swappiness can improve performance with zram
    "vm.swappiness" = 200;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    # Improve write and read performance
    # by caching pages in RAM
    # may cause OOM on large package builds
    # "vm.dirty_background_ratio" = 12;
  };

  # Automount USB and drives
  # for virtual file systems, removable media, and remote filesystems
  # udiskie (in hm config) does the job fine, so devmon not needed
  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.gnome-disks.enable = true;
  environment.systemPackages = with pkgs; [
    baobab # disk usage analyzer
    fuseiso # to mount iso system images
  ];
}
