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
  ];

  disabledModules = [
    # Disable specific modules
  ];

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      # Add custom overlays here for packages
      _64gram = inputs.nixpkgs-64gram-pin.legacyPackages.${pkgs.system}._64gram;
    })
  ];
}
