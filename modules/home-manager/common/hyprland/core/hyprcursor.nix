{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rose-pine-hyprcursor
  ];

  wayland.windowManager.hyprland.settings = {
    enable_hyprcursor = true;

    env = [
      "HYPRCURSOR_THEME, rose-pine-hyprcursor"
      "HYPRCURSOR_SIZE, 42"
    ];
  };
}
