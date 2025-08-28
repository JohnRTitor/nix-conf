{
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
let
  pkgs-open-webui-pin = import inputs.nixpkgs-open-webui-pin {
    system = pkgs.system;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      android_sdk.accept_license = true;
    };
  };
in
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
      open-webui = pkgs-open-webui-pin.open-webui;
    })
  ];
}
