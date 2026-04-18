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

  system.replaceDependencies.replacements = [
    {
      oldDependency = pkgs.pipewire;
      newDependency = pkgs.pipewire.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches or [ ] ++ [
          (pkgs.fetchpatch {
            name = "fix-speaker-headphones-simultaneous-output.patch";
            url = "https://gitlab.freedesktop.org/pipewire/pipewire/-/commit/f76327e076538b859bf05fff37188e92f3e1493a.patch";
            hash = "sha256-rj763p6vv1O4WPgR+Lg7sdLAocHsWjvPstQu1ykZSJs=";
          })
        ];
      });
    }
  ];
}
