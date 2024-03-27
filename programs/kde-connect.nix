{ pkgs, ... }:

{
  # No firewall configuration needed, handled by this option
  programs.kdeconnect.enable = true;
}