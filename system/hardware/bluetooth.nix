# Configure bluetooth settings
{ ... }:
{
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    # powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings.General = {
      Experimental = true; # enable bluetooth battery percentage features
      KernelExperimental = true;
    };
  };
  services.blueman.enable = true; # enables the Bluetooth manager
}
