{
  config,
  lib,
  systemSettings,
  servicesSettings,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./amd.nix
    ./audio.nix
    ./bluetooth.nix
    ./touchpad.nix
    ./disk.nix
    ./memory.nix
    ./graphics.nix
    ./tpm.nix
    ./touchpad.nix
  ];
}
