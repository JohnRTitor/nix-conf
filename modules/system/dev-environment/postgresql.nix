# Import of thie module is controlled by bool: config.myOptions.devSettings.postgresql
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.myOptions.devSettings.postgresql {
  # PostgreSQL service, can be accessed by CLI psql
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };

  environment.systemPackages = [ pkgs.pgadmin4-desktopmode ];
}
