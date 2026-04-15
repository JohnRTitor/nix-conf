/*
  Configure CLI tools here
  Bash Integration is disabled for some as they alias to existing commands
  And scripts may not work the high customised setup
*/
{ pkgs, ... }:
{
  # A better cat command
  programs.bat.enable = true;

  # eza, a modern replacement for ls
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      # extra flags to pass to eza
      "--git-repos" # show git directories repo status
      "--hyperlink" # display results as hyperlinks
    ];
    # disabled as some scripts may not work with eza
    enableBashIntegration = false;
  };

  # fastfetch, a neofetch like tool to fetch system information
  programs.fastfetch.enable = true;

  # fzf, a command-line fuzzy finder
  programs.fzf.enable = true;

  # zoxide, A smarter cd command which learns your habits as you go
  programs.zoxide = {
    enable = true;
    options = [
      # don't enable cd alias, as conflicts may occur sometimes
      # you might be redirected to a directory you didn't intend to
      # "--cmd cd" # Replace cd with zoxide
    ];
    enableBashIntegration = false;
  };

  # search recursively in all types of files, pdfs, text, inside tarballs, etc
  programs.ripgrep-all.enable = true;
  programs.ripgrep.enable = true;

  home.packages = with pkgs; [
    tree # List directory recursively in tree structure
  ];
}
