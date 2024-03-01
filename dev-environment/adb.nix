# This conf file is used to configure adb - android debug bridge
{ pkgs, userSettings, ... }:
{
  programs.adb.enable = true;
  users.users.${userSettings.username}.extraGroups = ["adbusers"];

  # configure the udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
}