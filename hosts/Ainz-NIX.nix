{
  config,
  inputs,
  self,
  pkgs-master,
  ...
}:
let
  inherit (inputs.nixpkgs) lib; # use lib from nixpkgs

  specialArgs = {
    inherit
      self
      inputs
      pkgs-master
      ;
  };
in
{
  flake.nixosConfigurations.Ainz-NIX = lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ### CORE SYSTEM & HOST CONFIGURATION ###
      {
        networking.hostName = "Ainz-NIX";
      }
      ../modules/system

      ### OPTIONS & PREFERENCES ###
      ../modules/preferences.nix
      ../modules/lib/options-definitions.nix

      ### OVERLAYS ###
      ../modules/modules-overlays

      ### NIX ECOSYSTEM & UTILS ###
      inputs.nur.modules.nixos.default # NUR - NixOS user repository

      ### SYSTEM COMPONENTS & SERVICES ###
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nix-flatpak.nixosModules.nix-flatpak # nix-flatpak, allows flatpak declaratively

      ### DESKTOP ENVIRONMENT & WINDOW MANAGER ###
      inputs.stylix.nixosModules.stylix

      ### USER PACKAGES AND APPS ###
      inputs.odysseus.nixosModules.default

      ### USER CONFIGURATION (HOME MANAGER) ###
      # Home Manager as NixOS module, this makes it so it is auto deployed with `nixos-rebuild switch`
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          #backupFileExtension = "hm.bak";
          extraSpecialArgs = specialArgs // {
            # extra arguments for home-manager
          };
        };

        home-manager.users =
          let
            commonImports = [
              ### FLAKE MODULES ###
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.noctalia.homeModules.default

              ### OPTIONS & PREFERENCES ###
              # To pass preferences and options definitions
              ../modules/preferences.nix
              ../modules/lib/options-definitions.nix

              ### LOCAL USER MODULES ###
              ../modules/pkgs-configuration/user-packages/common.nix
            ];
          in
          {
            "masum".imports = commonImports ++ [
              ../modules/home-manager/user-config/masum
              ../modules/pkgs-configuration/user-packages/masum.nix
            ];

            "masum-work".imports = commonImports ++ [
              ../modules/home-manager/user-config/masum-work.nix
              ../modules/pkgs-configuration/user-packages/masum-work.nix
            ];
          };
      }
    ];
  };
}
