# This conf file is used to configure adb - android debug bridge
{
  config,
  lib,
  ...
}:
lib.mkIf config.myOptions.devSettings.adb {
  # Enable adb
  programs.adb.enable = true;
}
