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
    ./ai-models
    ./apparmor.nix
    ./containers.nix
  ];

  /*
    ## Essential services ##
    # Enable xserver with xwayland
    services.xserver = {
      enable = true;
      # don't need xterm
      excludePackages = [ pkgs.xterm ];
    };
  */

  # Enable the sched_ext (BPF) user-space CPU scheduler daemon
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;

    # Choose the active scheduler target.
    # ---------------------------------------------------------------------------------
    # SCHEDULER COMPARISON & SELECTION EXPLANATIONS:
    #
    # * scx_lavd (Latency-criticality Aware Virtual Deadline):
    #   - Optimized heavily for gaming and handhelds (e.g., Steam Deck).
    #   - Focuses on consistent frame pacing and preventing 1% low framerate drops.
    #   - Supports the "--performance" flag to force aggressive execution behavior.
    #
    # * scx_rustland (The Safe Default):
    #   - Excellent, proven choice for general desktop workloads.
    #   - Balances throughput and responsiveness using a clean Rust design.
    #   - Highly stable fallback if experimental schedulers cause kernel hiccups.
    #
    # * scx_pandemonium (The Choice for Developers):
    #   - Exceptional for heavy coding, code completion (LSP), and extreme background tasks.
    #   - Automatically moves "compile storms" (cc1, rustc, make, cargo) into a background "Batch" tier.
    #   - Protects your UI, editor, and web browser from lagging while compiling at 100% CPU.
    #   - Supports the "--no-adaptive" flag to strip down processing overhead.
    # ---------------------------------------------------------------------------------

    scheduler = "scx_pandemonium";
    # extraArgs = [ "--performance" ];
  };

  # Accounts daemon is needed to remember passwords and other account information
  # by display manager and other services
  services.accounts-daemon.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker"; # use new dbus-broker
  };
  services.udev.enable = true;
  programs.dconf.enable = true;

  services.smartd.enable = true;

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
  security.polkit.enablePkexecWrapper = true;
  security.sudo-rs.enable = true; # Memory safe implementation of sudo in Rust

  # services.colord.enable = true; # For color management
}
