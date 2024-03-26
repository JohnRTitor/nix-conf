{ config, lib, ... }:
let
  # initial commands to run for all shells
  commonRcExtra = ''
    # Custom extraRc from home-manager/shell.nix
    # the below creates a wrapper function to print the command before executing it
    execmd() { echo "Executing: $@" && "$@" ; }
  '';

  # Define common aliases which would apply to all shells
  commonAliases = {
    check-flake = "execmd nix flake check";
    update-flake = "execmd nix flake update";
    rebuild = "execmd sudo nixos-rebuild switch --flake .";
    garbage-collect = "execmd sudo nix-collect-garbage -d";
    fix-store = "execmd sudo nix-store --verify --check-contents --repair";
    # cneofetch is just an alias to run compact neofetch
    # run in a subshell to avoid changing the current directory
    # because of neofetch can not source config files correctly using implicit home paths
    cneofetch = "(cd && neofetch --config .config/neofetch/config-compact.conf)";
  };

  # Define common session variables which would apply to all shells
  commonSessionVariables = {
    # Binds GPG to current tty
    GPG_TTY = "$(tty)";
    # Add custom bin directories to the PATH
    PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
  };

in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = commonRcExtra + ''
      # Custom bashrc go here, type below this line
    '';
    sessionVariables = commonSessionVariables // {
      # Add custom session variables for bash
    };

    shellAliases = commonAliases // {
      # set some aliases specific for bash
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    sessionVariables = commonSessionVariables // {
      # Add custom session variables for zsh
    };
    shellAliases = commonAliases // {
      # additional aliases to set for zsh
    };
    # extra lines to add to the zshrc file
    # Enable autosuggest to use history and completion
    initExtra = commonRcExtra + ''
      ZSH_AUTOSUGGEST_STRATEGY=(completion history match_prev_cmd)
    '';
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