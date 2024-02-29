{ pkgs, ... }: {
  home.packages = [ pkgs.neofetch ];
  home.file.".config/neofetch/config.conf".source = ./neofetch-config.conf;
  home.file.".config/neofetch/config.conf.save".source = ./neofetch-config.conf.save;
}