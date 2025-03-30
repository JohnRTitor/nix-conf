{
  config,
  lib,
  systemSettings,
  servicesSettings,
  ...
}:
{
  imports =
    [
      ./amd.nix
      ./audio.nix
      ./bluetooth.nix
      ./touchpad.nix
      ./disk.nix
      ./graphics.nix
    ]
    ++ lib.optionals systemSettings.laptop [
      ./touchpad.nix
    ]
    ++ lib.optionals servicesSettings.tpm [ ./tpm.nix ];

  services.ucodenix = {
    enable = true;
    # Use `cpuid | sed -n 's/^.*processor serial number = //p' | head -n1`
    # to get the serial number of your CPU
    # Use `cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'`
    # to get the model ID of your CPU
    cpuModelId = "00A60F12";
  };
}
