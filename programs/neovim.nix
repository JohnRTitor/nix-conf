{ pkgs, ... }:
{
  programs.neovim = {
    enable = true; # Enable Neovim
    vimAlias = true; # Enable vim alias
  };
}
