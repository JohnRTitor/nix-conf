{
  description = "NixOS configuration of JohnRTitor (Hyprland, Secure-Boot)";

  inputs = {
    ### CORE REPOSITORIES ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable NixOS system (default)
    nixpkgs-master.url = "github:NixOS/nixpkgs/master"; # Testing branch of nixpkgs

    ### SYSTEM SERVICES ###
    home-manager = {
      url = "github:nix-community/home-manager/master"; # Home Manager, manage user configuration and home directories like a pro
      inputs.nixpkgs.follows = "nixpkgs"; # Must follow nixpkgs, else will cause conflicts with the system
    };

    hyprland.url = "github:JohnRTitor/Hyprland";

    stylix.url = "github:nix-community/stylix";

    lanzaboote = {
      # Lanzaboote module used for Secure-Boot implementation
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.flake-parts.follows = "flake-parts";
      # If follows nixpkgs cause issues with package versions and boot experience, remove this
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/latest"; # Declarative Flatpak support for NixOS

    ### MISC PACKAGES ###
    determinate-nix = {
      url = "github:DeterminateSystems/nix-src";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake"; # Latest Zen Browser binary
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell"; # Latest Noctalia Shell
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions"; # Grab latest VScode extensions as a package;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR"; # Nix User Repository, for community packages
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    odysseus = {
      url = "github:ToyVo/odysseus/nix-add-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### UTILS ###
    flake-parts = {
      url = "github:hercules-ci/flake-parts"; # Flake parts for easy flake management
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ### NON-FLAKE REPOSITORIES ###
    platomav-microcode = {
      url = "github:platomav/CPUMicrocodes"; # For getting latest AMD microcode updates
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./flake ]; };

  ### Flake specific Nix configuration ###
  nixConfig = {
    # Allows the user to use these caches when using `nix run <thisFlake>`.
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://johnrtitor.cachix.org"
      "https://cache.numtide.com"
      "https://install.determinate.systems"
      # "https://cache.flakehub.com" # requires login
    ];
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "johnrtitor.cachix.org-1:CCJikn7FNkt2G4h2k1CmAaRzmNN+efiv349u/Hf93to="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
}
