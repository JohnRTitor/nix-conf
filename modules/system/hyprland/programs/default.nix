{ pkgs, self, ... }:
{
  imports = [
    ./file-manager.nix
  ];

  ## Configure essential packages ##

  environment.systemPackages =
    (with pkgs; [

    ])
    ++ [
      # self.packages.${pkgs.stdenv.hostPlatform.system}.weather-python-script # weather script'
    ];
}
