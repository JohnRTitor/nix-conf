# this config file is a wrapper to automatically configure pyprland via a config file
{ ... }:
{
  home.file.".config/hypr/pyprland.toml" = {
    source = ./pyprland.toml;
    executable = false;
  };
}