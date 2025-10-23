{ pkgs, ... }:
{
  # include zsh support, bash is enabled by default
  # this sources the necassary files for zsh
  programs.zsh.enable = true;
  # zsh is also enabled for user, conditionally at ../users.nix
  # set the user shell in ../../preferences.nix
}
