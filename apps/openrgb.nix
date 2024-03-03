{ pkgs, ... }:

{
  # OpenRGB setup
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins; # enable all plugins
  };
}