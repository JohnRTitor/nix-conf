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

      nnn # terminal file manager

      ## ARCHIVING TOOLS ##
      # p7zip

      # utils
      # ripgrep # recursively searches directories for a regex pattern
      # jq # A lightweight and flexible command-line JSON processor
      # yq-go # yaml processer https://github.com/mikefarah/yq
      # eza # A modern replacement for ‘ls’
      # fzf # A command-line fuzzy finder

      ## NETWORKING TOOLS ##
      # mtr # A network diagnostic tool
      # iperf3
      dnsutils  # `dig` + `nslookup`
      # ldns # replacement of `dig`, it provide the command `drill`
      # aria2 # A lightweight multi-protocol & multi-source command-line download utility
      # socat # replacement of openbsd-netcat
      # nmap # A utility for network discovery and security auditing
      # ipcalc  # it is a calculator for the IPv4/v6 addresses

      ## MISCELLANEOUS ##
      # cowsay
      # file
      # tree

      ## Productivity ##
      # hugo # static site generator
      # glow # markdown previewer in terminal

      # system call monitoring
      # strace # system call monitoring
      # ltrace # library call monitoring
      # lsof # list open files

      ## SYSTEM TOOLS ##
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      ## PERSONAL ENJOYMENT ##
      ani-cli

      ## GRAPHICAL APPS ##
      # Editors #
      # vscode
      # emacs
      # whatsapp-for-linux
      libreoffice-fresh
      discord
      telegram-desktop
      deluge
    ])
  
    ++

    # These packages are from Chaotic Nyx repo, optimised for x64-v3
    # If they don't work for you, replace pkgs.pkgsx86_64_v3 with pkgs
    # Most of the packages do not have binary cache, meaning nix will build them from source
    # which can potentially take a long time
    # Please don't try to build large, complex, or graphical packages, they will take a long time
    (with pkgs.pkgsx86_64_v3-core; [


      ## COMPRESSION TOOLS ##
      # zip, unzip are provided via global packages list
      gnutar
      # gzip
      # xz
      # bzip2
      # lz4
      # lzo
      # zlib
      zstd

      ## MISCELLANEOUS ##
      which
      gawk
      gnused
      
    ])

    ++

    (with pkgs-stable; [
      # list of latest packages from stable repo
      # Can be used to downgrade packages
      
    ])
  ;
}