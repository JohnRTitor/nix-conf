{
  config,
  inputs,
  self,
  pkgs-master,
  ...
}:
let
  inherit (inputs.nixpkgs) lib; # use lib from nixpkgs

  inherit (config.myOptions) systemSettings userSettings servicesSettings;

  specialArgs = {
    inherit
      self
      inputs
      pkgs-master
      systemSettings
      userSettings
      servicesSettings
      ;
  };
in
{
  flake = {
    nixosConfigurations.${systemSettings.hostname} = lib.nixosSystem {
      inherit specialArgs;
      modules = [
        ../default-host/configuration.nix # main nixos configuration
        inputs.chaotic.nixosModules.default # chaotic-nyx bleeding edge packages
        inputs.nur.modules.nixos.default # NUR - NixOS user repository
        inputs.ucodenix.nixosModules.ucodenix # ucodeNix - CPU microcode updates
        inputs.nix-flatpak.nixosModules.nix-flatpak # nix-flatpak, allows flatpak declaratively

        # install home-manager as NixOS module
        # so that it automatically gets deployed when running `nixos-rebuild switch`
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

          home-manager.users.${userSettings.username} = {
            imports = [
              ../home-manager
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
            ];
          };
        }
      ] ++ lib.optionals systemSettings.secureboot [ inputs.lanzaboote.nixosModules.lanzaboote ];
    };
  };
}
