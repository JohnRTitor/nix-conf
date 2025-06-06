{
  lib,
  pkgs,
  programsSettings,
  ...
}:
lib.mkIf programsSettings.neovim {
  programs.neovim = {
    enable = true; # Enable Neovim
    vimAlias = true; # Enable vim alias
  };
}
