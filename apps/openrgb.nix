{ pkgs, userSettings, ... }:

{
  # OpenRGB setup
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins; # enable all plugins
  };
  environment.systemPackages = [ pkgs.i2c-tools ];
  users.groups.i2c.members = [ userSettings.name ]; # create i2c group and add default user to it
}