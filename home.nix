{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  imports = [
    # system packages are imported in ./configuration.nix
    ./packages/user-packages.nix # user specific packages
    ./home-manager/shell.nix # shell (bash, zsh) config
    ./home-manager/git.nix # git config
    ./home-manager/starship/starship.nix # starship config
    ./home-manager/alacritty/alacritty.nix
    ./home-manager/pyprland/pyprland.nix # pyprland config wrapper
    ./home-manager/neofetch/neofetch.nix
    ./home-manager/vscode/vscode.nix
    ./home-manager/thunar/thunar.nix
  ]
  ++
  # Import if Virtualization is enabled
  lib.optionals (systemSettings.virtualisation) [
    ./home-manager/virt-manager/virt-manager.nix
  ];

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
  };


  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 1080p monitor
  # xresources.properties = {
  #   "Xcursor.size" = 24;
  #   "Xft.dpi" = 96; # for 4k - 172
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = systemSettings.stableversion;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
