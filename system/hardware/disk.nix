# Configure disks and zram
{ lib, ... }:
{
  # Enable support for bcachefs
  boot.supportedFilesystems = [ "bcachefs" ];
  fileSystems = {
  #  "/".options = [ "defaults" "noatime" ];
  };

  # Enable zram swap
  zramSwap.enable = true;

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
  environment.systemPackages = with lib; [
    gnome.gnome-disk-utility
  ];
}
