# Configure packages and softwares needed for virtualization
{
  config,
  pkgs,
  userSettings,
  ...
}:
{
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown"; # Shutdown VMs on host shutdown
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true; # allows VMs to access USB

  programs.virt-manager.enable = true;
  users.users."masum".extraGroups = [
    "libvirtd" # Needed for Virt Manager
    # "vboxusers" # Needed for Virtualbox
  ];

  # Enable Virtualbox
  # virtualisation.virtualbox.host.enable = true;
  # boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}
