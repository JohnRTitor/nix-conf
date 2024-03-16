{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  imports = [
    ./home-manager/shell.nix # shell (bash, zsh) config
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
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 96; # for 4k - 172
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    # editors
    # vscode
    # emacs

    nnn # terminal file manager

    # archives
    # zip
    xz
    # unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    # eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # graphical apps
    # whatsapp-for-linux
    libreoffice
    discord
    telegram-desktop
    deluge
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = userSettings.gitname;
    userEmail = userSettings.gitemail;
    signing.key = userSettings.gpgkey;
    signing.signByDefault = true;
    # compare diff using syntax
    difftastic.enable = true;
    extraConfig = {
      color.ui = true;
      # verbose messages
      commit.verbose = true;
      # always rebase when pulling
      pull.rebase = true;
    };
  };

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
