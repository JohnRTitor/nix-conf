# This config is used to configure the shell environment using home manager
# You can add custom aliases, session variables, and other shell configurations here
# NOTE: related global shell options like programs.zsh.enable must also be added to configuration.nix
# Else files may not be sourced properly
{ pkgs, ... }:
let
  inherit (import ./common.nix) commonAliases;
in
{
  imports = [
    ./bash.nix
    ./zsh.nix
    ./starship.nix
  ];
  # Define common aliases which would apply to all shells
  home.shellAliases = commonAliases;

  # automatically activate direnv on a per directory basis
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
  };

  # devenv is a faster and easier way to configure development
  # environment, better than nix-shell
  home.packages = [ pkgs.devenv ];
}
