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
    "${inputs.nixpkgs-ollama-test}/nixos/modules/services/misc/ollama.nix"
  ];

  disabledModules = [
    # Disable specific modules
    "${inputs.nixpkgs}/nixos/modules/services/misc/ollama.nix"
  ];

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default

    (final: prev: {
      #   open-webui = pkgs-master.open-webui;
      vesktop = prev.vesktop.override {
        pnpm_10_29_2 = final.pnpm_10;
      };
    })
  ];

  system.replaceDependencies.replacements = [
    # {
    #   oldDependency = pkgs.pipewire;
    #   newDependency = pkgs.pipewire.overrideAttrs (oldAttrs: {
    #     patches = oldAttrs.patches or [ ] ++ [
    #       (pkgs.fetchpatch {
    #         name = "fix-speaker-headphones-simultaneous-output.patch";
    #         url = "https://gitlab.freedesktop.org/pipewire/pipewire/-/commit/f76327e076538b859bf05fff37188e92f3e1493a.patch";
    #         hash = "sha256-rj763p6vv1O4WPgR+Lg7sdLAocHsWjvPstQu1ykZSJs=";
    #       })
    #     ];
    #   });
    # }
  ];
}
