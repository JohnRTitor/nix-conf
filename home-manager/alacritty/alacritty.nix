# this config file is a wrapper to configure alacritty
{ pkgs, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty.enable = true;
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty-config.toml;
}