# Configure systemd-boot (non-secureboot)
{ ... }:
{
  # Enable systemd-boot
  boot.loader.systemd-boot.enable = true;
}