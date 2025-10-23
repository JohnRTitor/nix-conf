# Import of thie module is controlled by bool: config.myOptions.devSettings.nginx
{ config, lib, pkgs, ... }:
lib.mkIf config.myOptions.devSettings.nginx {
  # MySQL service, can be accessed by cli mariadb
  # or a graphical frontend like adminer
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  # mycli is a MySQL cli helper with auto-completion and syntax highlighting
  environment.systemPackages = with pkgs; [ mycli ];
}
