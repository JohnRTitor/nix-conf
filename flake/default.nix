{
  config,
  lib,
  inputs,
  ...
}:
let
  # bleeding edge packages from nixpkgs master branch, for packages that need immediate updates
  pkgs-master = import inputs.nixpkgs-master {
    system = config.myOptions.systemSettings.systemarch;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      android_sdk.accept_license = true;
    };
  };
in
{
  imports = [
    ./hosts.nix # NixOS hosts/desktop systems are are defined there
    ../lib/options-definitions.nix
    ../preferences.nix
  ];

  _module.args = { inherit pkgs-master; };

  # systems for which you want to build the `perSystem` attributes
  systems = lib.unique [
    config.myOptions.systemSettings.systemarch
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      # Setting this option, allows formatting via `nix fmt`
      formatter = pkgs.nixfmt-rfc-style;

      # Packages defined in the flake, derivations usually reside in `../pkgs/`
      # Use `nix flake show` to see the list of packages
      # To access packages from this flake, use `self'.packages.<name>`
      packages = {
        fhs-shell = pkgs.callPackage ../pkgs/fhs-shell.nix { };
        weather-python-script = pkgs.callPackage ../pkgs/weather-python-script.nix { };
        adminneo-with-theme = pkgs.callPackage ../pkgs/adminneo-with-theme { };
        google-chrome_repackaged = pkgs.callPackage ../pkgs/google-chrome-repackaged.nix { };
        vscode_repackaged = pkgs.callPackage ../pkgs/vscode-repackaged.nix { };
      };
    };
}
