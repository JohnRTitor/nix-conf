{ config, ... }:
{
  # Enable touchpad support if laptop mode is enabled
  services.libinput.enable = true;
}
