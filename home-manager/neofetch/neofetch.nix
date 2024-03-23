# this config file is a wrapper to automatically configure neofetch
{ pkgs, ... }:
{
  home.packages = [ pkgs.neofetch ];
  home.file.".config/neofetch/config.conf".source = ./neofetch-default.conf;
  home.file.".config/neofetch/config-compact.conf".source = ./neofetch-compact.conf;
  home.file.".config/neofetch/config.conf.save".source = ./neofetch-config.conf.save;
}