{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-master,
  ...
}:

{
  imports = [
    ./llama-cpp.nix
    ./ollama.nix
    ./ui.nix
  ];
}
