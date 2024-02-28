{

  description = "Flake of JohnRTitor";

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
      # follow the stable nixpkgs, to ensure compatibility
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, lanzaboote, home-manager, ... }:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "Ainz-NIX"; # hostname
        timezone = "Asia/Kolkata"; # select timezone
        locale = "en_US.UTF-8"; # select locale
        localeoverride = "en_IN.UTF-8"; # select locale
        stableversion = "23.11";
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
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
        # overlays = [ rust-overlay.overlays.default ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
        # overlays = [ rust-overlay.overlays.default ];
      };

      # configure lib
      lib = nixpkgs.lib;
    in {
      nixosConfigurations.${systemSettings.hostname} = lib.nixosSystem {
        system = systemSettings.system;

        modules = [
          ./configuration.nix # main nix configuration
          lanzaboote.nixosModules.lanzaboote # lanzaboote for secureboot

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

        ];
        specialArgs = {
          inherit pkgs-unstable;
          inherit systemSettings;
          inherit userSettings;
        };
      };
    };

}
