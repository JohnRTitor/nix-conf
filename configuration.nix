# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, pkgs-unstable, systemSettings, userSettings, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Enable zram swap
  zramSwap.enable = true;

  # bootspec needed for secureboot - MR 22-02
  boot.bootspec.enable = true;
  # Add Xanmod Kernel - MR - 22-02
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # Bootloader - disable systemd in favor of lanzaboote
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  # bootloader timeout set, also press t repeatedly in the bootmenu to set there
  boot.loader.timeout = 15;

  # lanzaboote for secureboot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # plymouth theme for splash screen
  # boot.kernelParams = [ "quiet" ];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.initrd.systemd.enable = true;

  # Update amd-ucode
  hardware.cpu.amd.updateMicrocode = true;

  # enable bluetooth support
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # enables the Bluetooth manager
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings.General.Experimental = true; # enable bluetooth battery percentage features

  networking.hostName = systemSettings.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # For KDE connect - MR - 22-02
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable experimental flakes packages - MR 22-02
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = systemSettings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
  };

  # ----- HYPRLAND SPECIFIC CONFIG START ----- #

  # Enable OpenGL
  hardware.opengl = {
    enable = true; # Mesa
    driSupport = true; # Vulkan
    driSupport32Bit = true;
    # Extra drivers
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
      vaapiVdpau
      libvdpau-va-gl
    ];
    # For 32 bit applications 
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
      libva
    ];
  };


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
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    ];
  };


  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
      excludePackages = [ pkgs.xterm ];
      # AMDGPU graphics driver - disabled in favor of modesetting driver
      # videoDrivers = ["amdgpu"];
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

    # fstrim for SSD
    fstrim = {
      enable = true;
      interval = "monthly";
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

      curl
      openssh
      gnupg
      sbctl

      # System Packages
      baobab
      btrfs-progs
      cpufrequtils
      # firewalld
      ffmpeg   
      git
      glib #for gsettings to work   
      libappindicator
      libnotify
      openssl # required by Rainbow borders
      python3
      pipewire
      unzip  
      vim
      wget
      wireplumber
      xdg-user-dirs
      
      # I normally have and use
      audacious
      mpv
      mpvScripts.mpris
      neofetch
      shotcut
      gparted
          
      # Hyprland Stuff        
      blueman
      btop
      cava
      cliphist
      gnome.file-roller
      gnome.gnome-system-monitor
      gnome.eog # eye of gnome
      grim
      jq
      kitty
      networkmanagerapplet
      nwg-look
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pywal
      qt6Packages.qtstyleplugin-kvantum #kvantum
      libsForQt5.qtstyleplugin-kvantum #kvantum
      # QT Wayland
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      rofi-wayland
      slurp
      swappy
      swayidle
      swaylock-effects
      swaynotificationcenter
      swww
      # QT Control Center
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      wl-clipboard
      wlogout
      xdg-utils
      xdg-desktop-portal-hyprland
      yad 
      libva-utils # graphics library

      # EXTRA PACKAGES - May not needed but should be tested first

      fuseiso # to mount iso system images
      udiskie
      gnome.adwaita-icon-theme
      gnome.gnome-themes-extra
      gsettings-desktop-schemas
      wlr-randr
      ydotool
      hyprland-protocols
      hyprpicker
      hyprpaper
      # wofi # alternative to rofi
      waybar
      grim
      adwaita-qt
      adwaita-qt6

    ])

    ++

    (with pkgs-unstable; [
      # list of latest packages from unstable repo
      vscode
      google-chrome
      firefox-wayland
    ]);


  # Environment variables to start the session with
  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    LIBVA_DRIVER_NAME = "amdgpu";
    XDG_SESSION_TYPE = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "amdgpu";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
  }; 


  # ----- HYPERLAND SPECIFIC CONFIG END ----- #


  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable flatpak
  services.flatpak.enable = true;
  # enable fwupd
  services.fwupd.enable = true;
  # Mitigate issue where like /usr/bin/bash, hardcoded links in scripts not found
  services.envfs.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  # SECURITY
  security = {
    pam.services.swaylock.text = "auth include login";
    };
    polkit.enable = true; # Enable polkit for root prompts
    rtkit.enable = true;
  }; 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "input" "audio" ];
    packages = with pkgs; [
      # firefox
      # kate
      # google-chrome
      # thunderbird

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
  

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
