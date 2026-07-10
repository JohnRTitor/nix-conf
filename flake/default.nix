{
  config,
  lib,
  inputs,
  ...
}:
let
  mkPkgs =
    nixpkgs: system:
    import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        android_sdk.accept_license = true;
      };
    };

  # bleeding edge packages from nixpkgs master branch, for packages that need immediate updates
  pkgs-master = mkPkgs inputs.nixpkgs-master config.myOptions.systemSettings.systemarch;
in
{
  imports = [
    ../hosts/Ainz-NIX.nix # Ainz-NIX host configuration
    ../modules/lib/options-definitions.nix
    ../modules/preferences.nix
  ];

  _module.args = { inherit pkgs-master; };

  # systems for which you want to build the `perSystem` attributes
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    let
      pkgs-unfree = mkPkgs inputs.nixpkgs config.myOptions.systemSettings.systemarch;
    in
    {
      # Setting this option, allows formatting via `nix fmt`
      formatter = pkgs.nixfmt;

      # Packages defined in the flake, derivations usually reside in `../pkgs/`
      # Use `nix flake show` to see the list of packages
      # To access packages from this flake, use `self'.packages.<name>`
      packages = {
        fhs-shell = pkgs.callPackage ../packages/fhs-shell.nix { };
        bonafides-rounded-kvantum = pkgs.callPackage ../packages/bonafides-rounded-kvantum { };
        utterly-sweet-kvantum = pkgs.callPackage ../packages/utterly-sweet-kvantum { };
        weather-python-script = pkgs.callPackage ../packages/weather-python-script.nix { };
        adminneo-with-theme = pkgs.callPackage ../packages/adminneo-with-theme { };
        google-chrome_repackaged = pkgs-unfree.callPackage ../packages/google-chrome-repackaged.nix { };
        microcode-amd-platomav = pkgs-unfree.callPackage ../packages/microcode-amd-platomav {
          microcode-src = inputs.platomav-microcode;
        };
      };
    };
}
