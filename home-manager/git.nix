{ userSettings, ... }:
{
  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = userSettings.gitname;
    userEmail = userSettings.gitemail;
    signing.key = userSettings.gpgkey;
    signing.signByDefault = true;
    # compare diff using syntax
    difftastic.enable = true;
    extraConfig = {
      color.ui = true;
      # verbose messages
      commit.verbose = true;
      # always rebase when pulling
      pull.rebase = true;
    };
  };
}