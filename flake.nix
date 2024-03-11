{
  description = "Flake of JohnRTitor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Unstable nixpkgs
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11"; # Stable nixpkgs (23.11)

    lanzaboote.url = "github:nix-community/lanzaboote"; # lanzaboote, used for secureboot

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # follow the stable nixpkgs, to ensure compatibility
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, home-manager, ... }:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        systemarch = "x86_64-linux"; # system arch
        hostname = "Ainz-NIX"; # hostname
        timezone = "Asia/Kolkata"; # select timezone
        locale = "en_US.UTF-8"; # select locale
        localeoverride = "en_IN";
        stableversion = "24.05";
        secureboot = true;
      };

      # ----- USER SETTINGS ----- #
      userSettings = {
        username = "masum"; # username
        name = "Masum R."; # name/identifier
        email = "masumrezarock100@gmail.com"; # email (used for certain configurations)
        gitname = "John Titor"; # git name
        gitemail = "50095635+JohnRTitor@users.noreply.github.com"; # git email
        gpgkey = "29B0514F4E3C1CC0"; # gpg key
      };

      # configure stable pkgs
      pkgs = import nixpkgs {
        # Add zen4 support
        localSystem = let
          featureSupport = arch:
          nixpkgs.lib.mapAttrs (_: f: f arch) nixpkgs.lib.systems.architectures.predicates;
        in {
          system = systemSettings.systemarch;
        } // featureSupport "znver4";

        config = { allowUnfree = true;
                  allowUnfreePredicate = (_: true); };
      };
      pkgs-stable = import nixpkgs-stable {
        # Add zen4 support
        localSystem = let
          featureSupport = arch:
          nixpkgs-stable.lib.mapAttrs (_: f: f arch) nixpkgs-stable.lib.systems.architectures.predicates;
        in {
          system = systemSettings.systemarch;
        } // featureSupport "znver4";

        config = { allowUnfree = true;
                  allowUnfreePredicate = (_: true); };
      };

    in {
      nixosConfigurations.${systemSettings.hostname} = nixpkgs.lib.nixosSystem {
        system = systemSettings.systemarch;

        modules = [
          ./configuration.nix # main nix configuration

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${userSettings.username} = import ./home.nix;
            # extra specialArgs is used to pass arguments to home-manager
            home-manager.extraSpecialArgs = {
              inherit pkgs-stable;
              inherit systemSettings;
              inherit userSettings;
            };
          }

        ]
        ++
        # Enable Lanzaboote if secureboot is configured
        ( if (systemSettings.secureboot == true) then
            [ lanzaboote.nixosModules.lanzaboote ]
          else
            [] # empty wrapper
        );
        specialArgs = {
          inherit pkgs-stable;
          inherit systemSettings;
          inherit userSettings;
        };
      };
    };

}
