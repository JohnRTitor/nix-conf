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
        
        ];
      theme = "agenoster";
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };
    shellAliases = {
      
    };
  };

}