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

  environment.systemPackages = [
    inputs.colibri.packages.${pkgs.hostPlatform.system}.colibri
    pkgs.lmstudio
  ];
}
