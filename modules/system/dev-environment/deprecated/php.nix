## DEPRECATED - use devenv instead ##
# This config files is used for configuring a PHP development environment
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ php ];
}
