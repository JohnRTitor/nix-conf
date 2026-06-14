{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs.btop-rocm;
    extraConfig = builtins.readFile ./btop.conf;
  };

  xdg.configFile."btop/themes" = {
    source = ./themes;
    recursive = true;
  };
}
