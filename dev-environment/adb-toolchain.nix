# This conf file is used to configure adb - android debug bridge
{ pkgs, userSettings, ... }:

{
  # Enable adb
  programs.adb.enable = true;
  # Add our primary user to adbusers group
  users.users.${userSettings.username}.extraGroups = [ "adbusers" "plugdev" ];

  # configure the udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
}