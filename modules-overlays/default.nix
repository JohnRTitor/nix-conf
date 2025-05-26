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
    ./lact.nix
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
