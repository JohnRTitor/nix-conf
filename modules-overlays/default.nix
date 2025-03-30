{
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  imports = [
    #./amdgpu.nix # import modules here to test
    "${inputs.nixpkgs-master}/nixos/modules/services/display-managers/cosmic-greeter.nix"
    "${inputs.nixpkgs-master}/nixos/modules/services/desktop-managers/cosmic.nix"
  ];

  disabledModules = [
    # Disable specific modules
  ];

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      # Add custom overlays here for packages
    })
  ];
}
