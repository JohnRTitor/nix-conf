# this config file is a wrapper to automatically configure neofetch
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neofetch
    psmisc # fuser command (used by neofetch)
    lsof # list open files (used by neofetch)
  ];

  home.file.".config/neofetch/config.conf".source = ./neofetch-default.conf;
  home.file.".config/neofetch/config-compact.conf".source = ./neofetch-compact.conf;
  home.file.".config/neofetch/config.conf.save".source = ./neofetch-config.conf.save;
}