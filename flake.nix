{
  description = "Flake of JohnRTitor (Hyprland, Secure-Boot)";

  outputs = { self, nixpkgs, nixpkgs-stable, chaotic, nix-vscode-extensions, lanzaboote, home-manager, ... }:
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
        virtualisation = true;
      };

      # ----- USER SETTINGS ----- #
      userSettings = {
        username = "masum"; # username
        name = "Masum R."; # name/identifier
        email = "masumrezarock100@gmail.com"; # email (used for certain configurations)
        gitname = "John Titor"; # git name
        gitemail = "50095635+JohnRTitor@users.noreply.github.com"; # git email
        gpgkey = "29B0514F4E3C1CC0"; # gpg key
        shell = "zsh"; # user default shell # choose either zsh or bash
      };

      # configure pkgs from unstable (default)
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
      # configure packages from stable repo, used for downgrading specific packages
      pkgs-stable = import nixpkgs-stable {
        system = systemSettings.systemarch;
        config = { allowUnfree = true;
                  allowUnfreePredicate = (_: true); };
      };
      # configure vscode extensions flake
      # Mainly used in ./home-manager/vscode/vscode.nix
      pkgs-vscode-extensions = nix-vscode-extensions.extensions.${systemSettings.systemarch};

      # system is built on nixos unstable 
      lib = nixpkgs.lib;
      # pass the custom settings and flakes to system
      specialArgs = {
        inherit pkgs-stable;
        inherit pkgs-vscode-extensions;
        inherit systemSettings;
        inherit userSettings;
      };

    in {
      nixosConfigurations.${systemSettings.hostname} = lib.nixosSystem {
        system = systemSettings.systemarch;

        modules = [
          ./configuration.nix # main nix configuration
          chaotic.nixosModules.default # chaotic nix bleeding edge packages

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${userSettings.username} = import ./home.nix;
            # extra specialArgs is used to pass arguments to home-manager
            home-manager.extraSpecialArgs = specialArgs // {
              # Additional arguments for home-manager
            };
          }

        ]
        ++
        # Enable Lanzaboote if secureboot is configured
        lib.optionals (systemSettings.secureboot) [
          lanzaboote.nixosModules.lanzaboote 
        ];
        inherit specialArgs;
      };
    };
    
  # Main sources and repositories
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Unstable NixOS packages (default)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11"; # Stable NixOS packages (23.11)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # Bleeding edge packages from chaotic nix

    lanzaboote.url = "github:nix-community/lanzaboote"; # lanzaboote, used for secureboot

    # home-manager, used for managing user configuration, should follow system nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # vs code extensions
  };
  
}
