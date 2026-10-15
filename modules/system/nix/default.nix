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
  #
  # `packages.<system>.nix` in the determinate-nix flake is `nix-everything`, which
  # sets `doCheck = true` and pulls the entire Nix test suite in as `checkInputs`
  # (nix-util-tests, nix-store-tests, nix-expr-tests, nix-fetchers-tests,
  # nix-flake-tests, nix-functional-tests and their `*-test-support` libs).
  #
  # Those are build-time-only derivations, so they are not part of the runtime
  # closure. `cachix push` is fed the top-level output path from `--print-out-paths`
  # and only ever publishes that runtime closure, so the test derivations never
  # reach any cache. Every cache miss on the top-level path (e.g. right after a
  # flake.lock bump) then rebuilds and re-runs the whole test suite locally.
  #
  # Keep `nix-everything` rather than switching to `nix-cli`: the nix-daemon
  # ExecStart references `${nixPackage}/libexec/nix-nswrapper`, which only the
  # `nix-everything` output provides. Dropping the build gate is enough, because
  # nixpkgs only adds `checkInputs` to `nativeBuildInputs` when `doCheck` is set.
  nix.package = inputs.determinate-nix.packages.${pkgs.stdenv.hostPlatform.system}.nix.overrideAttrs (
    _: {
      doCheck = false;
    }
  );

  # THIS IS REQUIRED BUT ALSO DANGEROUS
  # main user has access to nix store
  # THIS IS EQUIVALENT TO GIVING ROOT ACCESS TO THE MAIN USER
  # DO NOT DISABLE THIS
  nix.settings.trusted-users = [
    "masum"
    "masum-work"
  ]; # FIXME: if someday custom cache works without this

  # Optimise daemon priority so builds do not lag the system
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

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
