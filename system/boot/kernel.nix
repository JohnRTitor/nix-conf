# This config file is used to configure the kernel
{
  config,
  pkgs,
  pkgs-master,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "ZEN4"; };
}
