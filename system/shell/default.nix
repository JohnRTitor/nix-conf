{ pkgs, ... }:
{
  # include zsh support, bash is enabled by default
  # this sources the necassary files for zsh
  programs.zsh.enable = true;
  # zsh is also enabled for user, conditionally at ../users.nix
  # set the user shell in ../../preferences.nix

  # automatically activate direnv on a per directory basis
  programs.direnv = {
    enable = true;
    silent = true;
  };

  # devenv a newer way for nix-shell
  environment.systemPackages = [ pkgs.devenv ];
}
