# Configure bluetooth settings
{ ... }:

{
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # enables the Bluetooth manager
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings.General.Experimental = true; # enable bluetooth battery percentage features
}