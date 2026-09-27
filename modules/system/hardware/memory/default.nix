{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./zram.nix
    ./swaps.nix
    ./oomd.nix
  ];
}
