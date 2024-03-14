{ pkgs, ... }:

{
  # Wrapped KDE Connect service, this uses GSConnect instead
  # No firewall configuration needed, handled by this option
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
}