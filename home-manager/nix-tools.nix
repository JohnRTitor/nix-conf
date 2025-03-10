{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    ## NixPkgs development ##
    nh # provides `nh os switch` commands
    nix-output-monitor # provides nom as an alternative to nix command
    nvd # for nixos version diff
    nixpkgs-review # can build/run tests from a PR/rev
  ];
  home.shellAliases = {
    # See ./shell.nix for definition of execmd
    rebuild = "FLAKE=${config.home.homeDirectory}/nix-conf execmd nh os switch";
    garbage-collect = "execmd nh clean all";
    test-rebuild = "FLAKE=${config.home.homeDirectory}/nix-conf execmd nh os test";
  };
}
