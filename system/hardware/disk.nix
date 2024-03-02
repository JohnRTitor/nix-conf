# Configure disks and zram
{ ... }:
{
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

  # Automount USB and drives
  # for virtual file systems, removable media, and remote filesystems 
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}