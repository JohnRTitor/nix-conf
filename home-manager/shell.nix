{ config, lib, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # add your cusotm bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    sessionVariables = {
      GPG_TTY = "$(tty)";
    };

    # set some aliases, feel free to add more or remove some
    shellAliases = {
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
    shellAliases = {
      # aliases to set
      rebuild = "sudo nixos-rebuild switch --flake .";
      garbage-collect = "sudo nix-collect-garbage -d";
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