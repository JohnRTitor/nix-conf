{ config, lib, ... }:
let
  # Define common aliases which would apply to all shells
  commonAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .";
    garbage-collect = "sudo nix-collect-garbage -d";
    fix-store = "sudo nix-store --verify --check-contents --repair";
    cneofetch = "neofetch --config ~/.config/neofetch/config-compact.conf";
  };
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      # Custom bashrc go here, type below this line
    '';
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };

    shellAliases = commonAliases // {
      # set some aliases specific for bash
      # k = "kubectl";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };
    shellAliases = commonAliases // {
      # additional aliases to set for zsh
    };
    # Enable autosuggest to use history and completion
    initExtra = ''
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