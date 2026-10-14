# Configure disks
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

  # Automount USB and drives
  # for virtual file systems, removable media, and remote filesystems
  # udiskie (in hm config) does the job fine, so devmon not needed
  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
