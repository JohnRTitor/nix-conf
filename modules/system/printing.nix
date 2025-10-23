# Configure printers
{
  lib,
  pkgs,
  servicesSettings,
  ...
}:
{
  # Enable CUPS to print documents.
  services.printing = lib.mkIf servicesSettings.printing {
    enable = true;
    # cups-pdf.enable = true; # Enable seperate PDF printing virtual printer
    openFirewall = true; # Open ports for printing
  };
  # Enable Avahi to discover printers, and LAN devices
  services.avahi = lib.mkIf servicesSettings.avahi {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
