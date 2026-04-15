{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;
      bezier = [
        "wind, -1.05, 0.9, 0.1, 1.05"
        "winIn, -1.1, 1.1, 0.1, 1.1"
        "winOut, -1.3, -0.3, 0, 1"
        "liner, 0, 1, 1, 1"
      ];
      animation = [
        "windows, 0, 6, wind, slide"
        "windowsIn, 0, 6, winIn, slide"
        "windowsOut, 0, 5, winOut, slide"
        "windowsMove, 0, 5, wind, slide"
        "border, 0, 1, liner"
        "fade, 0, 10, default"
        "workspaces, 0, 5, wind"
      ];
    };
  };
}
