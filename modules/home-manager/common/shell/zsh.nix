{
  config,
  lib,
  pkgs,
  self,
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
    # The content is one string, because home-manager merges this option with
    # the antidote module's, and the merge follows the order the modules are
    # evaluated in rather than `mkOrder`. Putting the shell-pulse source at
    # the end of this string is therefore what puts it last in the .zshrc.
    initContent = lib.mkOrder 1000 ''
      ${commonRcExtra}

      # shell-pulse: incremental syntax highlighting & fast native completion in Rust.
      #
      # Replaces fast-syntax-highlighting and marlonrichert/zsh-autocomplete
      # with sub-microsecond latency and zero subshells.
      source ${self.packages.${pkgs.stdenv.hostPlatform.system}.shell-pulse}/share/shell-pulse/init.zsh
    '';

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
