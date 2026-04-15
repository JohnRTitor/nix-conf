{
  # Hyprland Settings
  # Examples:
  # extraMonitorSettings = "monitor = Virtual-1,1920x1080@60,auto,1";
  # extraMonitorSettings = "monitor = HDMI-A-1,1920x1080@60,auto,1";
  # You can configure multiple monitors.
  # Inside the quotes, create a new line for each monitor.
  extraMonitorSettings = "
   monitor = Virtual-1,1920x1080@60,auto,1
    ";

  # Waybar Settings (used when barChoice = "waybar")
  clock24h = false;

  # Program Options
  # Set Default Browser (google-chrome-stable for google-chrome)
  # This does NOT install your browser
  # You need to install it by adding it to the `packages.nix`
  # or as a flatpak
  browser = "google-chrome";

  # Host-level default applications (picked up by Home Manager xdg.mimeApps)
  # Uncomment and adjust the .desktop IDs to set per-host defaults.
  # mimeDefaultApps = {
  #   # PDFs
  #   "application/pdf" = ["okular.desktop"];
  #   "application/x-pdf" = ["okular.desktop"];
  #   # Web browser
  #   "x-scheme-handler/http"  = ["google-chrome.desktop"];  # or brave-browser.desktop, firefox.desktop
  #   "x-scheme-handler/https" = ["google-chrome.desktop"];
  #   "text/html"              = ["google-chrome.desktop"];
  #   # Files
  #   "inode/directory" = ["thunar.desktop"];      # file manager
  #   "text/plain"      = ["nvim.desktop"];        # or code.desktop
  # };

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Themes, waybar and animation.
  #  Only uncomment your selection
  # The others much be commented out.

  # Set Stylix Image
  # This will set your color palette
  # Default background
  # Add new images to ~/zaneyos/wallpapers
  #stylixImage = ../wallpapers/mountainscapedark.jpg;
  #stylixImage = ../wallpapers/AnimeGirlNightSky.jpg;
  #stylixImage = ../wallpapers/Anime-Purple-eyes.png;
  #stylixImage = ../wallpapers/purple_gasstation_abstract_dark_night.jpg;
  stylixImage = ../wallpapers/Fantasy-Japanese-Street.png;
  #stylixImage = ../wallpapers/zaney-wallpaper.jpg;
  #stylixImage = ../wallpapers/nix-wallpaper-stripes-logo.png;
  #stylixImage = ../wallpapers/beautifulmountainscape.jpg;

  # Set Waybar
  #  Available Options:
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-dwm.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-dwm-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jerry.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-TheBlackDon.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-tony.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubsos-v1.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-mecha.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-ml4w-modern.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-oglo-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-transparent.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-ultradark.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-pctrade-catppuccin.nix;
  waybarChoice = ../../modules/home/waybar/waybar-mangowc-jak-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-old-ddubsos.nix;

  # Set Animation style
  # Available options are:
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations-end-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;
  #animChoice = ../../modules/home/hyprland/animations-hyde-optimized.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-1.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-2.nix;
  animChoice = ../../modules/home/hyprland/animations-ml4w-classic.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-fast.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-high.nix;
}
