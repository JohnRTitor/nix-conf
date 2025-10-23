{ lib, pkgs, ... }:
{
  programs.hyprpanel.enable = true;

  xdg.configFile."hyprpanel/modules.json".text = builtins.toJSON {
    "custom/wl-logout" = {
      icon = " ⏻";
      label = "";
      executeOnAction = "wlogout";
    };
  };
}
