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
      {
        networking.hostName = "Ainz-NIX";
      }

      ### FLAKE MODULES ###
      inputs.chaotic.nixosModules.default # chaotic-nyx bleeding edge packages
      inputs.nur.modules.nixos.default # NUR - NixOS user repository
      inputs.nix-flatpak.nixosModules.nix-flatpak # nix-flatpak, allows flatpak declaratively
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.determinate.nixosModules.default # Determinate Nix

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
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.nixvim.homeModules.nixvim

              # To pass preferences and options definitions
              ../modules/preferences.nix
              ../modules/lib/options-definitions.nix

              ../modules/pkgs-configuration/user-packages/common.nix
            ];
          in
          {
            "masum".imports = commonImports ++ [
              ../modules/home-manager/user-config/masum.nix
              ../modules/pkgs-configuration/user-packages/masum.nix
            ];

            "masum-work".imports = commonImports ++ [
              ../modules/home-manager/user-config/masum-work.nix
              # ../modules/pkgs-configuration/user-packages/masum-work.nix
            ];
          };
      }

      ## LOCAL MODULES ##
      ../modules/system
      ../modules/modules-overlays

      # To pass preferences and options definitions
      ../modules/preferences.nix
      ../modules/lib/options-definitions.nix
    ];
  };
}
