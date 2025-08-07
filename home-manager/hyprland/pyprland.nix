{ pkgs, ... }:
let
  pyprlandSettings = {
    pyprland = {
      plugins = ["scratchpads" "magnify"];
    };

    "scratchpads.term" = {
      animation = "fromTop";
      command = "kitty --class kitty-dropterm";
      class = "kitty-dropterm";
      size = "75% 60%";
    };
  };
in {
  xdg.configFile."pypr/pyprland.toml".source = (pkgs.formats.toml { }).generate "pyprland-config.toml" pyprlandSettings;

  home.packages = with pkgs; [
    pyprland
  ];
}
