# Configure printers
{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    cups-pdf.enable = true; # Enable PDF printing.
    openFirewall = true; # Open ports for printing
  };
  # Enable Avahi to discover printers, and LAN devices
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
