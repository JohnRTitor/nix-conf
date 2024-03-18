# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, lib, pkgs, pkgs-stable, pkgs-vscode-extensions, systemSettings, userSettings, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # include boot and kernel settings
    ./system/boot/kernel.nix
    ./system/boot/boot-options.nix
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

    # include global/system packages list
    ./packages/global-packages.nix
    # user packages are imported in ./home.nix

    # include APPS settings
    ./apps/openrgb.nix
    #./apps/kde-connect.nix
      
    # include adb settings
    ./dev-environment/adb.nix

    # include custom cache server settings
    #./misc/custom-cache-server.nix # disabled temporarily cause it messes up nix-shell
  ]
  ++
  # Configure secure boot with lanzaboote, if secureboot is enabled
  lib.optionals (systemSettings.secureboot) [
    ./system/boot/lanzaboote.nix
  ]
  ++
  # Import if Virtualization is enabled
  lib.optionals (systemSettings.virtualisation) [
    ./system/virtualisation.nix
  ];

  networking.hostName = systemSettings.hostname; # Define your hostname in flake.nix
  
  # include zsh support, bash is enabled by default
  # this only includes zsh package
  programs.zsh.enable = true;
  # zsh is also enabled for user, conditionally at ./system/users.nix
  # set the user shell in ./flake.nix

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix command and flakes
  nix.settings.auto-optimise-store = true; # enable deleting duplicate content in store

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
