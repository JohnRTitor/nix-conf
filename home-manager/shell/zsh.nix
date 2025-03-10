{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./common.nix) commonSessionVariables commonRcExtra;
in
{
  imports = [ ./zsh-plugins.nix ];

  programs.zsh = {
    enable = true;
    sessionVariables = commonSessionVariables // {
      # Add custom session variables for zsh
    };

    autosuggestion.strategy = [
      "history"
      "completion"
      "match_prev_cmd"
    ];
    shellAliases = {
      # additional aliases to set for zsh
    };
    # extra lines to add to the zshrc file
    initExtra = commonRcExtra;
  };

  # If starship is enabled, don't enable oh-my-zsh
  programs.zsh.oh-my-zsh = lib.mkIf (config.programs.starship.enable == false) {
    enable = true;
    plugins = [
      "git"
      "history"
      "urltools" # provides urlencode, urldecode
    ];
    theme = "duellj";
  };
}
