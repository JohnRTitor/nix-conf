# This config file is used to configure the XDG user directories and MIME types
# which is responsible for opening specific files, links in specific apps
# Imported in home manager ../home.nix

{ config, ... }:
let
  homeDir = config.home.homeDirectory;
in
{
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${homeDir}/Media/Music";
    videos = "${homeDir}/Media/Videos";
    pictures = "${homeDir}/Media/Pictures";
    templates = "${homeDir}/Templates";
    download = "${homeDir}/Downloads";
    documents = "${homeDir}/Documents";
    # can be null since hyprland does not use Desktop
    desktop = "${homeDir}/Desktop"; # null;
    publicShare = "${homeDir}/Public";
    
    extraConfig = {
      # XDG_DOTFILES_DIR = "${homeDir}/.dotfiles";
      XDG_ARCHIVE_DIR = "${homeDir}/Archive";
      # XDG_VM_DIR = "${homeDir}/Machines";
      # XDG_ORG_DIR = "${homeDir}/Org";
      XDG_PODCAST_DIR = "${homeDir}/Media/Podcasts";
      XDG_BOOK_DIR = "${homeDir}/Media/Books";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  # Desktop entries are located in /run/current-system/sw/share/applications/
  # For programs installed using home manager /etc/profiles/per-user/{user}/share/applications/
  # Chrome PWAs are located in ~/.local/share/applications/
  xdg.mimeApps.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "inode/directory" = "thunar.desktop"
    "application/pdf" = "org.gnome.Evince.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
  };
  xdg.mimeApps.associations.added = {
    # Text files
    "text/plain" = "org.xfce.mousepad.desktop;";
    "application/x-shellscript" = "org.xfce.mousepad.desktop;";
    "application/json" = "org.xfce.mousepad.desktop;code.desktop;";
    "application/xml" = "org.xfce.mousepad.desktop;";
    "application/x-executable" = "Alacritty.desktop";
    # Open directory with apps
    "inode/directory" = "thunar.desktop;org.gnome.Nautilus.desktop;nnn.desktop;code.desktop;org.gnome.baobab.desktop;";
    # Telegram
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop;";
    "x-xdg-protocol-tg" = "org.telegram.desktop.desktop;";

    # Images
    "image/png" = "org.gnome.eog.desktop;";
    "image/jpeg" = "org.gnome.eog.desktop;";

    # PDF
    "application/pdf" = "org.gnome.Evince.desktop;google-chrome.desktop;";
  };
}