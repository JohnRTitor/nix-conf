{ pkgs, lib, ... }:
let
  lua = import ../utils/lua.nix { inherit lib; };
  inherit (lua) args;
in
{
  home.packages = with pkgs; [
    rose-pine-hyprcursor
  ];

  wayland.windowManager.hyprland.settings = {
    config = {
      cursor = {
        enable_hyprcursor = true;
      };
    };

    env = [
      (args [
        "HYPRCURSOR_THEME"
        "rose-pine-hyprcursor"
      ])
      (args [
        "HYPRCURSOR_SIZE"
        "42"
      ])
    ];
  };
}
