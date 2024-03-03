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
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
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
      theme = "duellj";
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };
    shellAliases = {
      
    };
  };

}