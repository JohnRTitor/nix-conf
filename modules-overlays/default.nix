{
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}: {
  imports = [
    #./amdgpu.nix # import modules here to test
  ];

  disabledModules = [
    # Disable specific modules
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # Add custom overlays here
    })
  ];
}
