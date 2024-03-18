# This config file is used to define system/global packages
# this file is imported ../configuration.nix
# User specific packages should be installed in ./user-packages.nix
# Some packages/apps maybe handled by config options
# They are scattered in ../system/ ../home-manager/ and ../apps/ directories

{ pkgs, pkgs-stable, ... }:
{
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

      ## FILE MANAGERS ##
      gnome.nautilus

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

      # Tool to run app images and random app binaries
      (let base = pkgs.appimageTools.defaultFhsEnvArgs; in 
        pkgs.buildFHSUserEnv (base // {
          name = "fhs"; # provides fhs command to enter in a FHS environment
          targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
          profile = "export FHS=1";
          runScript = "$SHELL";
          extraOutputsToInstall = ["dev"];
      }))

    ])

    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      # Can be used to downgrade packages
      
    ])
  ;
    
  # Enable Firefox Wayland
  programs.firefox = {
  	enable = true;
  	package = pkgs.firefox-wayland;
  };
}