# This config file is used to configure the kernel
{
  config,
  pkgs,
  pkgs-master,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  boot.kernelParams = [
    # Switch to lazy preemption for better performance
    # as desktops don't need full rt like preempt support
    # https://lwn.net/Articles/994322/
    # Verify with sudo cat /sys/kernel/debug/sched/preempt
    "preempt=lazy"
  ];
}
