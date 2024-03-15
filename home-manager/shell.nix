{ ... }:
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
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git"
        "history"
        "urltools" # provides urlencode, urldecode
        "history-substring-search"
        ];
      theme = "duellj";
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };
    shellAliases = {
      
    };
  };
  # starship - an customizable prompt for any shell
  # programs.starship = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };
}