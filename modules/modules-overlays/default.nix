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
    })
  ];
  
  system.replaceDependencies.replacements = with pkgs; [
    {
      oldDependency = pkgs.pipewire;
      newDependency = pkgs.pipewire.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches or [] ++ [
          ./0001-alsa-acp-don-t-override-user-selected-port-on-availa.patch
        ];
      });
    }
  ];
}
