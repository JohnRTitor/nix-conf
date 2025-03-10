{ lib, ... }:
{
  # Zsh plugins'
  programs.zsh.autosuggestion.enable = true; # enable autosuggestion plugin
  programs.zsh.antidote.enable = true; # Plugin manager
  programs.zsh.antidote.plugins = [
    # Note the order, it's important: https://github.com/zsh-users/zsh-syntax-highlighting/issues/951
    "zdharma-continuum/fast-syntax-highlighting"
    "marlonrichert/zsh-autocomplete"
  ];
  programs.zsh.enableCompletion = lib.mkForce false; # disable for zsh autocomplete plugin

  # programs.zsh.historySubstringSearch.enable = true; # not compatible with zsh-autocomplete
}
