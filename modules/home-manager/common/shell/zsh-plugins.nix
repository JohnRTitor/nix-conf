{ ... }:
{
  # Zsh plugins
  # Both fast-syntax-highlighting and marlonrichert/zsh-autocomplete are
  # replaced by zsh-pulse (in Rust), which provides sub-microsecond
  # incremental syntax highlighting, bounded completion without subshell hangs,
  # and fast history autosuggestions.
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.antidote.enable = false;
  programs.zsh.enableCompletion = true;
}
