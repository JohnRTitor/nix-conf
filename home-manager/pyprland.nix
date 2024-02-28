{ config, ... }:

{
  home.file = {
    home.homeDirectory+"/.config/hypr/pyprland.toml" = {
      source = "./pyprland.toml";
      executable = false;
    };
  };
}