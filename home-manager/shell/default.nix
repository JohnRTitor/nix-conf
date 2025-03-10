# This config is used to configure the shell environment using home manager
# You can add custom aliases, session variables, and other shell configurations here
# NOTE: related global shell options like programs.zsh.enable must also be added to configuration.nix
# Else files may not be sourced properly
{ ... }:
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
}
