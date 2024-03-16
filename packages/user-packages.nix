# This config file is used to define user specific packages
# installed using home manager, this file is imported in ../home.nix
# System/Global packages should be installed in ./system-packages.nix
# Some packages/apps maybe handled by config options
# They are scattered in ../system/ ../home-manager/ and ../apps/ directories

{ pkgs, pkgs-stable, ... }:
{
  home.packages = 
    (with pkgs; [
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

      ## GRAPHICAL APPS ##
      # whatsapp-for-linux
      libreoffice-fresh
      discord
      telegram-desktop
      deluge
    ])
  
    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      # Can be used to downgrade packages
      
    ])
  ;
}