{
  lib,
  pkgs,
  programsSettings,
  ...
}:
lib.mkIf programsSettings.openrgb {
  # OpenRGB setup
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb_git; # enable all plugins
  };
  environment.systemPackages = [ pkgs.i2c-tools ];
  # MAKE SURE TO ADD YOUR USER TO THE I2C GROUP
  # sudo groupadd --system i2c
  # sudo usermod -aG i2c $USER
}
