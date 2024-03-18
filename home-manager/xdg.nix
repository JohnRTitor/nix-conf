# This config file is used to configure the XDG user directories and MIME types
# which is responsible for opening specific files, links in specific apps
# Imported in home manager ../home.nix

{ config, ... }:
{
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Media/Music";
    videos = "${config.home.homeDirectory}/Media/Videos";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = "${config.home.homeDirectory}/Desktop"; # null; # hyprland does not use desktop
    publicShare = "${config.home.homeDirectory}/Public"; # null;
    
    extraConfig = {
      # XDG_DOTFILES_DIR = "${config.home.homeDirectory}/.dotfiles";
      XDG_ARCHIVE_DIR = "${config.home.homeDirectory}/Archive";
      # XDG_VM_DIR = "${config.home.homeDirectory}/Machines";
      # XDG_ORG_DIR = "${config.home.homeDirectory}/Org";
      XDG_PODCAST_DIR = "${config.home.homeDirectory}/Media/Podcasts";
      XDG_BOOK_DIR = "${config.home.homeDirectory}/Media/Books";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
    "x-scheme-handler/tg" = "userapp-Telegram Desktop-TLQ2K2.desktop";
  };
  xdg.mimeApps.associations.added = {
    # Text files
    "text/plain" = "org.xfce.mousepad.desktop;";
    "application/x-shellscript" = "org.xfce.mousepad.desktop;";
    "application/json" = "org.xfce.mousepad.desktop;code.desktop;";
    "application/xml" = "org.xfce.mousepad.desktop;";
    "inode/directory" = "code.desktop;";
    # Telegram
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop;userapp-Telegram Desktop-TLQ2K2.desktop;";
    "x-xdg-protocol-tg" = "org.telegram.desktop.desktop;userapp-Telegram Desktop-TLQ2K2.desktop;";

    # Images
    "image/png" = "org.gnome.eog.desktop;";
    "image/jpeg" = "org.gnome.eog.desktop;";

    # PDF
    "application/pdf" = "google-chrome.desktop;";
  };
}