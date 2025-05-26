{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lact;
in
{
  meta.maintainers = [ lib.maintainers.johnrtitor ];

  options.services.lact = {
    enable = lib.mkEnableOption "LACT, for monitoring andconfiguring GPUs";

    package = lib.mkPackageOption pkgs "lact" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.lactd = {
      description = "LACT GPU Control Daemon";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
