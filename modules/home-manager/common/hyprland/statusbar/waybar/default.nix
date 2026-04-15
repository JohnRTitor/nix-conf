{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.myOptions.programsSettings.statusbar == "waybar") {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };
}
