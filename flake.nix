{

  description = "Flake file of John Titor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    lanzaboote.url = "github:nix-community/lanzaboote";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, ... }:
    let
      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
    # TODO replace Ainz-NIX with actual hostname
      Ainz-NIX = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix # main nix configuration
          lanzaboote.nixosModules.lanzaboote # lanzaboote for secureboot

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.masum = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }

        ];
      };
    };
  };

}
