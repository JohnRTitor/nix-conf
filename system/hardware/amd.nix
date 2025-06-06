{
  config,
  pkgs,
  pkgs-master,
  ...
}:
{
  boot.kernelParams = [
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html#active-mode
    "amd-pstate=active"
  ];

  # And do NOT use Zenpower because it lacks support for 7000 series

  # load the latest microcode from ucodenix flake
  services.ucodenix = {
    enable = true;
    # Use `cpuid | sed -n 's/^.*processor serial number = //p' | head -n1`
    # to get the serial number of your CPU
    # Use `cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'`
    # to get the model ID of your CPU
    cpuModelId = "00A60F12";
  };
}
