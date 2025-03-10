# This config can be used to configure git via home manager
{
  pkgs,
  userSettings,
  ...
}:
{
  programs.git = {
    # basic configuration of git, please change to your own
    enable = true;
    package = pkgs.gitFull;
    userName = userSettings.gitname;
    userEmail = userSettings.gitemail;
    signing.key = userSettings.gpgkey;
    signing.signByDefault = true;
    extraConfig = {
      color.ui = true;
      # verbose messages
      commit.verbose = true;
      # always rebase when pulling
      pull.rebase = true;
      # automatically convert crlf line endings to lf when commiting
      core.autocrlf = "input";
    };
    lfs.enable = true; # git lfs for large files
    diff-so-fancy.enable = true;

    # difftastic.enable = true; # enables difft command
  };
  programs.gh = {
    # GitHub CLI
    enable = true;
    settings.git_protocol = "ssh";
  };
}
