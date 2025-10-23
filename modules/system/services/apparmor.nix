{
  lib,
  pkgs,
  servicesSettings,
  ...
}:
lib.mkIf servicesSettings.apparmor {
  security.apparmor.enable = true;
  security.apparmor.enableCache = true;
  services.dbus.apparmor = "enabled";
  security.apparmor.packages = with pkgs; [
    apparmor-profiles
  ];
}
