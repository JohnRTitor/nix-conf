{ ... }:
{
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
