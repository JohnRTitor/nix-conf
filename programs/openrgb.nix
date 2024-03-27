{ pkgs, userSettings, ... }:

{
  # OpenRGB setup
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins; # enable all plugins
  };
  environment.systemPackages = [ pkgs.i2c-tools ];
  # MAKE SURE TO ADD YOUR USER TO THE I2C GROUP
  # sudo groupadd --system i2c
  # sudo usermod -aG i2c $USER
}