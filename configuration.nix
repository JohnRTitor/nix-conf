# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, pkgs-unstable, systemSettings, userSettings, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # include boot settings
      ./system/boot.nix
      # include hardware settings
      ./system/hardware.nix
      # include network settings
      ./system/network.nix
      # include audio settings
      ./system/audio.nix
      # include locale settings
      ./system/locale.nix
    ];

  networking.hostName = systemSettings.hostname; # Define your hostname.

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix command and flakes
  nix.settings.auto-optimise-store = true; # enable deleting duplicate content in store

  # ----- HYPRLAND SPECIFIC CONFIG START ----- #

  programs = {
    # Enable Hyperland
    hyprland.enable = true;
    waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
    # Xfce file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo
        mousepad
        thunar-archive-plugin
        thunar-volman
        tumbler
      ];
    };

    dconf.enable = true;
    partition-manager.enable = true; # KDE Partition Manager
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal
  };


  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      excludePackages = [ pkgs.xterm ];
      libinput.enable = true;
      # Enable GDM
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    
    # For thunar to work better
    gvfs.enable = true;
    tumbler.enable = true;

    dbus.enable = true;
    udev.enable = true;
    gnome = {
      sushi.enable = true;
      gnome-keyring.enable = true;
    };
  };

  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk
    jetbrains-mono
    font-awesome
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [

      # System Packages
      ananicy-cpp # for better system performance
      baobab
      btrfs-progs # for btrfs filesystem
      # cpufrequtils
      curl
      # firewalld
      ffmpeg # codecs
      fuseiso # to mount iso system images
      git # obviously
      glib # for gsettings to work
      gnupg # for encryption and auth keys
      libappindicator
      libnotify
      openssh # for ssh
      openssl # required by Rainbow borders
      python3
      pipewire
      sbctl # for secureboot
      udiskie # automount usb drives
      unzip  
      vim
      wget
      wireplumber
      
      # I normally have and use
      audacious
      mpv # for video playback, needed for some scripts
      mpvScripts.mpris
      neofetch
      shotcut
          
      # Hyprland Stuff        
      # blueman # not needed if blueman service is on
      btop
      cava
      cliphist
      gnome.file-roller
      gnome.gnome-system-monitor
      gnome.eog # eye of gnome
      grim
      jq
      kitty # default terminal on hyprland
      libva-utils # graphics library
      libsecret # needed for gnome-keyring
      networkmanagerapplet
      nwg-look
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pyprland # hyprland plugin support
      pywal
      rofi-wayland
      slurp
      swappy
      swayidle
      swaylock-effects
      swaynotificationcenter
      swww
      # Can control theming on QT apps
      # QT Wayland
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      # Kvantum
      qt6Packages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      # QT control center
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      # waybar # included by default for hyprland.waybar.enable
      wl-clipboard
      wlogout
      xdg-utils
      # xdg-desktop-portal-hyprland - included by default for hyprland.enable
      xdg-user-dirs
      xorg.xhost # needed for some packages running x11 like gparted
      yad

      # EXTRA PACKAGES - May not needed but should be tested first

      gsettings-desktop-schemas
      wlr-randr
      ydotool
      hyprland-protocols
      # hyprpicker # does not work
      # hyprpaper # alternative to swww
      # wofi # alternative to rofi-wayland
      grim
      # test vs code opening codespace
      shared-mime-info
      desktop-file-utils
      
      google-chrome
    ])

    ++

    (with pkgs-unstable; [
      # list of latest packages from unstable repo
      vscode
      firefox-wayland
    ]);


  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    WLR_NO_HARDWARE_CURSORS = "1"; # if your cursor is not visible
    NIXOS_OZONE_WL = "1"; # for electron apps to run on wayland
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1"; # makes dialogs (file opening) consistent with rest of the ui
  }; 

  # ----- HYPERLAND SPECIFIC CONFIG END ----- #

  # disable hibernate since you can't hibernate on zram swap anyway
  systemd.targets.hibernate = {
    enable = false;
    unitConfig.DefaultDependencies = "no";
	};
  # Fix opening links in apps like vscode
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';


  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable flatpak
  services.flatpak.enable = true;
  # enable fwupd
  services.fwupd.enable = true;
  # Mitigate issue where like /usr/bin/bash, hardcoded links in scripts not found
  services.envfs.enable = true;


  # SECURITY
  security = {
    pam.services.swaylock.text = "auth include login";
    polkit.enable = true; # Enable polkit for root prompts
    # rtkit is enabled in audio config
  }; 


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "input" "audio" ];
    packages = with pkgs; [
        # Configure in ./home.nix
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };
  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = systemSettings.stableversion; # Did you read the comment?
}
