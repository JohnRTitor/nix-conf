# Configure printers
{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true; # Enable PDF printing.
  services.printing.openFirewall = true; # Open ports for printing
  # Enable Avahi to discover printers, and LAN devices
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;
}
