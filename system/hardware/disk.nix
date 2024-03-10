# Configure disks and zram
{ ... }:
{
  # Enable support for bcachefs
  boot.supportedFilesystems = [ "bcachefs" ];
  # Enable zram swap
  zramSwap.enable = true;
  # Disable last access time to increase performance
  fileSystems = {
  #  "/".options = [ "noatime" ];
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