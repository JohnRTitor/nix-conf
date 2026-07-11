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

  # Enable ZSwap
  # DO NOT ENABLE ZSWAP IF YOU HAVE ZRAM ON
  # ZSWAP WILL CONFLICT WITH ZRAM
  # boot.kernel.sysfs.module.zswap.parameters.enabled = 1;

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

  # Automount USB and drives
  # for virtual file systems, removable media, and remote filesystems
  # udiskie (in hm config) does the job fine, so devmon not needed
  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
