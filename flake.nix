{

  description = "Flake file of John Titor";

  inputs = {
    # Stable nixpkgs (23.11)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # lanzaboote, used for secureboot
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

  outputs = { self, nixpkgs, lanzaboote, home-manager, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in {
    nixosConfigurations = {
    # TODO replace Ainz-NIX with actual hostname
      Ainz-NIX = lib.nixosSystem {
        inherit system;

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
        specialArgs = {
          inherit pkgs-unstable;
        };
      };
    };
  };

}
