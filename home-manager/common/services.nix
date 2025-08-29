{ pkgs, ... }:
{
  # services.udisks2 must be enabled in system configuration else mounting will fail
  services.udiskie.enable = true;
}
