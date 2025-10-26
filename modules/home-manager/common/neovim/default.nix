{ config, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.moonfly.enable = true;
    plugins.lualine.enable = true;
  };
}
