{ ... }: {
  stylix.targets = {
    # Avoid fetching GNOME Shell sources on non-GNOME systems (breaks on some remotes)
    gnome.enable = false;
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    hyprlock.enable = false;
    ghostty.enable = false;
    vscode.enable = false;
    kitty.enable = false;
    qt = {
      enable = false; # QT is handled by Kvantum
      # platform = "qtct";
    };
  };
}
