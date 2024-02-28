{ config, ... }:

{
  home.file.".config/hypr/pyprland.toml" = {
    source = ./pyprland.toml;
    executable = false;
  };
}