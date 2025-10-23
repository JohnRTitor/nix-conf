{ config, lib, ... }:
lib.mkIf config.myOptions.systemSettings.laptop {
  # Enable touchpad support if laptop mode is enabled
  services.libinput.enable = true;
}
