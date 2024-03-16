# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # include boot and kernel settings
    ./system/boot-kernel.nix
    # include user account settings
    ./system/users.nix
    # include hardware settings
    ./system/hardware/audio.nix
    ./system/hardware/bluetooth.nix
    ./system/hardware/disk.nix
    ./system/hardware/graphics.nix
    # include network settings
    ./system/network.nix
    # include locale settings
    ./system/locale.nix
    # include fonts settings
    ./system/fonts.nix
    # include hyprland settings
    ./system/hyprland.nix
    # include printing settings
    ./system/printing.nix
    # include power plan settings
    ./system/power.nix

    # include APPS settings
    ./apps/openrgb.nix
    #./apps/kde-connect.nix
      
    # include adb settings
    ./dev-environment/adb.nix

    # include custom cache server settings
    ./misc/custom-cache-server.nix
  ]
  ++
  # Import if Virtualization is enabled
  lib.optionals (systemSettings.virtualisation) [
    ./system/virtualisation.nix
  ];

  networking.hostName = systemSettings.hostname; # Define your hostname.
  
  # enable zsh
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ]; # add symlink to system/run for zsh autocompletion
  # zsh is also enabled for user at ./system/users.nix

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix command and flakes
  nix.settings.auto-optimise-store = true; # enable deleting duplicate content in store

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [

      # System Packages
      ananicy-cpp # for better system performance
      baobab # disk usage analyzer
      # cpufrequtils
      # firewalld
      ffmpeg # codecs
      fuseiso # to mount iso system images
      git # obviously
      glib # for gsettings to work
      gnupg # for encryption and auth keys
      libappindicator
      libnotify
      linux-wifi-hotspot # for wifi hotspot
      openssh # for ssh
      python3
      # pipewire # enabled via service
      udiskie # automount usb drives
      zip
      unzip
      # wireplumber # enabled via service

      ## BROWSERS ##

      # firefox, chrome from unstable are incompatible with stable
      (google-chrome.override {
        # enable video encoding and hardware acceleration, along with several
        # suitable for my configuration
        # change it if you have any issues
        # note the spaces, they are required
        # Vulkan is not stable, likely because of drivers
        commandLineArgs = ""
          + " --enable-accelerated-video-decode"
          + " --enable-accelerated-mjpeg-decode"
          + " --enable-gpu-compositing"
          + " --enable-gpu-rasterization" # dont enable in about:flags
          + " --enable-native-gpu-memory-buffers"
          + " --enable-raw-draw"
          + " --enable-zero-copy" # dont enable in about:flags
          + " --ignore-gpu-blocklist" # dont enable in about:flags
          # + " --use-vulkan"
          + " --enable-features="
              + "VaapiVideoEncoder,"
              + "CanvasOopRasterization,"
              # + "Vulkan"
          ;
      })

      ## URL FETCH TOOLS ##
      curl
      wget

      ## EDITOR ##
      vim
      vscode

      ## MONITORING TOOLS ##
      btop # for CPU, RAM, and Disk monitoring
      nvtop-amd # for AMD GPUs
      iotop # for disk I/O monitoring
      iftop # for network I/O monitoring
    ])

    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      # Can be used to downgrade packages
      
    ]);
    
  # Enable Firefox Wayland
  programs.firefox = {
  	enable = true;
  	package = pkgs.firefox-wayland;
  };

  # SECURITY
  security = {
    pam.services.swaylock.text = "auth include login";
    polkit.enable = true; # Enable polkit for root prompts
    # rtkit is enabled in audio config
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
  
  # enable time synchronization
  services.timesyncd.enable = true;
  # Enable flatpak
  services.flatpak.enable = true;
  # enable fwupd
  services.fwupd.enable = true;
  # Mitigate issue where like /usr/bin/bash, hardcoded links in scripts not found
  services.envfs.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = systemSettings.stableversion; # Did you read the comment?
}
