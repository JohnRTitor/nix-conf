# Configure virt-manager
{ config, lib, ... }:
lib.mkIf config.myOptions.servicesSettings.virtualisation {
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
