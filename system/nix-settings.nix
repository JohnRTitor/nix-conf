{
  config,
  pkgs,
  pkgs-master,
  userSettings,
  ...
}:
{
  nix.package = pkgs.nixVersions.latest; # Use latest nix
  # DONOT DISABLE THIS
  nix.settings.trusted-users = [ "masum" ]; # FIXME: if someday custom cache works without this

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]; # enable nix command and flakes

  nix.settings.auto-optimise-store = true; # enable space optimisation by hardlinking

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  nixpkgs.config.android_sdk.accept_license = true;

  programs.ssh.knownHosts."darwin-build-box.nix-community.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMHhlcn7fUpUuiOFeIhDqBzBNFsbNqq+NpzuGX3e6zv";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        # https://nix-community.org/community-builder/
        hostName = "darwin-build-box.nix-community.org";
        maxJobs = 6;
        sshKey = "/root/.ssh/id_ed25519_nix_com";
        sshUser = "johnrtitor";
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        supportedFeatures = [
          "big-parallel"
          "nixos-test"
          "benchmark"
        ];
      }
    ];
  };
}
