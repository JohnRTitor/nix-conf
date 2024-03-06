{
  description = "Flake of JohnRTitor";

  outputs = { self, nixpkgs, nixpkgs-unstable, browserPreviews, lanzaboote, home-manager, ... }@inputs:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        systemarch = "x86_64-linux"; # system arch
        hostname = "Ainz-NIX"; # hostname
        timezone = "Asia/Kolkata"; # select timezone
        locale = "en_US.UTF-8"; # select locale
        localeoverride = "en_IN";
        stableversion = "23.11";
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
      pkgs-unstable = import nixpkgs-unstable {
        # Add zen4 support
        localSystem = let
          featureSupport = arch:
          nixpkgs-unstable.lib.mapAttrs (_: f: f arch) nixpkgs-unstable.lib.systems.architectures.predicates;
        in {
          system = systemSettings.systemarch;
        } // featureSupport "znver4";
        config = { allowUnfree = true;
                   allowUnfreePredicate = (_: true); };
      };
      pkgs-browser = import browserPreviews {
        system = systemSettings.systemarch;
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
              inherit pkgs-unstable;
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
        # Arguments to configuration.nix
        specialArgs = {
          inherit pkgs-unstable;
          inherit pkgs-browser;
          inherit systemSettings;
          inherit userSettings;
        };
      };
    };
  # Inputs of Flake, define sources here
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Stable nixpkgs (23.11)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Unstable nixpkgs

    lanzaboote.url = "github:nix-community/lanzaboote"; # lanzaboote, used for secureboot

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs"; # follow the stable nixpkgs, to ensure compatibility
    };
    browserPreviews = {
      url = "github:r-k-b/browser-previews";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

}
