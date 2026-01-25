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
    /*
      Common order values:
      - 500 (mkBefore: Early initialization (replaces initExtraFirst
      - 550: Before completion initialization (replaces initExtraBeforeCompInit
      - 1000 (default: General configuration (replaces initExtra
      - 1500 (mkAfter: Last to run configuration
    */
    initContent = lib.mkOrder 1000 commonRcExtra;
    
    dotDir = "${config.xdg.configHome}/zsh";
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
