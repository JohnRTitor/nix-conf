# This config file is used to configure the kernel
{
  config,
  pkgs,
  pkgs-master,
  ...
}:
{
  boot.kernelPackages = pkgs-master.linuxPackages_latest;
}
