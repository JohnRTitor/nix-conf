{

  description = "My first flake!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    lanzaboote.url = "github:nix-community/lanzaboote";
  };

  outputs = { self, nixpkgs, lanzaboote, ... }:
    let
      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
      Ainz-NIX = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          lanzaboote.nixosModules.lanzaboote # lanzaboote for secureboot
        ];
      };
    };
  };

}
