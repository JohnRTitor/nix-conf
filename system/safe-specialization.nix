{
  lib,
  pkgs,
  pkgs-master,
  ...
}: {
  # Creates a second boot entry with xanmod kernel and scx disabled
  specialisation.safe.configuration = {
    system.nixos.tags = ["vanilla"];
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    services.scx.enable = lib.mkForce false;
  };
}
