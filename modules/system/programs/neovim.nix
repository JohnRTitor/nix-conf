{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.myOptions.programsSettings.neovim {
  programs.neovim = {
    enable = true; # Enable Neovim
    vimAlias = true; # Enable vim alias
  };
}
