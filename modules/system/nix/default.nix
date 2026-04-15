{
  config,
  pkgs,
  inputs,
  userSettings,
  ...
}:
{
  imports = [
    ./builders.nix
    ./cache-servers.nix
  ];
  
  # Use Determinate Nix, from their nix source, without determinate-nixd daemon and proprietary stuff
  nix.package = inputs.determinate-nix.packages.${pkgs.stdenv.hostPlatform.system}.nix;
  
  # THIS IS REQUIRED BUT ALSO DANGEROUS
  # main user has access to nix store
  # THIS IS EQUIVALENT TO GIVING ROOT ACCESS TO THE MAIN USER
  # DO NOT DISABLE THIS
  nix.settings.trusted-users = [
    "masum"
    "masum-work"
  ]; # FIXME: if someday custom cache works without this

  # Parallel Evaluation (only available in Determinate Nix)
  nix.settings.eval-cores = 0;
  
  # Features for building
  nix.settings.system-features = [
    # Defaults
    "big-parallel"
    "benchmark"
    "kvm"
    "nixos-test"
    # Additional
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4"
    "gccarch-znver4"
  ];
  
  # enable nix command and flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]; 

  # enable space optimisation by hardlinking
  nix.settings.auto-optimise-store = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  # DONT USE THIS UNLESS YOU KNOW WHAT YOU ARE DOING
  # socks5 proxy might speed up downloads in some cases
  # but most of the time it won't work leading to you not able to rebuild and fix your system
  # systemd.services.nix-daemon.environment.https_proxy = "socks5h://localhost:7891"; # socks5 proxy
  # systemd.services.nix-daemon.environment.https_proxy = "http://localhost:7890"; # https proxy
}
