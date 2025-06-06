# Configure system services
{
  config,
  lib,
  pkgs,
  pkgs-master,
  systemSettings,
  servicesSettings,
  ...
}:
{
  imports = [
    ./ananicy-cpp.nix
    ./console-tty.nix
    ./gnome-keyring.nix
    ./gnupg-ssh.nix
    ./ai-models.nix
    ./apparmor.nix
    ./containers.nix
  ];

  ## Essential services ##
  # Enable xserver with xwayland
  services.xserver = {
    enable = true;
    # don't need xterm
    excludePackages = [ pkgs.xterm ];
  };

  # Enable scx extra schedulers, only available for linux-cachyos
  services.scx.enable = true;
  services.scx.package = pkgs-master.scx.full;
  # lavd is better for gaming
  # rustland is better for general workloads
  services.scx.scheduler = "scx_lavd";

  # Accounts daemon is needed to remember passwords and other account information
  # by display manager and other services
  services.accounts-daemon.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker"; # use new dbus-broker
  };
  services.udev.enable = true;
  programs.dconf.enable = true;

  ## Configure XDG portal ##
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal
  };

  /*
    # Not used anywhere
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "${pkgs.kitty}/share/applications/kitty.desktop"
        ];
        GNOME = [
          "com.raggesilver.BlackBox.desktop"
          "org.gnome.Terminal.desktop"
        ];
      };
    };
  */

  # XDG portal paths to link if useUserPackages=true is enabled in home-manager (flake.nix)
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

  services.timesyncd.enable = true; # For time synchronization
  services.fwupd.enable = true; # For firmware updates
  # Mitigate issue where like /usr/bin/bash, hardcoded links in scripts not found
  services.envfs.enable = true;

  security.polkit.enable = true; # Enable polkit for elevated prompts
  security.sudo-rs.enable = true; # Memory safe implementation of sudo in Rust

  # services.colord.enable = true; # For color management
}
