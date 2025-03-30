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

  # And do not use Zenpower because it lacks support for 7000 series
}
