# This config can be used to configure git via home manager
{
  config,
  pkgs,
  userSettings,
  ...
}:
{
  programs.git = {
    # basic configuration of git, please change to your own
    enable = true;
    package = pkgs.gitFull;

    settings = {
      user.name = config.myOptions.userSettings.${config.home.username}.gitname;
      user.email = config.myOptions.userSettings.${config.home.username}.gitemail;

      signing.key = config.myOptions.userSettings.${config.home.username}.gpgkey;
      signing.format = "openpgp";
      signing.signByDefault = true;

      color.ui = true;
      commit.verbose = true; # show diff of changes in commit message editor
      pull.rebase = true; # rebase by default when pulling
      core.autocrlf = "input"; # automatically convert crlf line endings to lf when commiting
      format.signOff = true; # signoff at the end of each commit every time
      diff.algorithm = "histogram"; # better diff algorithm for git diff

    };
    lfs.enable = true; # git lfs for large files

    # difftastic.enable = true; # enables difft command
  };

  programs.gh = {
    # GitHub CLI
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.diff-so-fancy.enable = true; # better git diff output
  programs.diff-so-fancy.enableGitIntegration = true;
}
