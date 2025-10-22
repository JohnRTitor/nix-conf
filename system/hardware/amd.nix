{
  config,
  pkgs,
  pkgs-master,
  self,
  ...
}:
{
  boot.kernelParams = [
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html#active-mode
    "amd-pstate=active"
  ];

  # And do NOT use Zenpower because it lacks support for 7000 series

  # load the latest microcode from platomav's repository
  hardware.cpu.amd.microcodePackage =
    self.packages.${pkgs.hostPlatform.system}.microcode-amd-platomav;
}
