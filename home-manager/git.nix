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
    userName = if (config.home.username == "masum-work") then "Masum Reza" else userSettings.gitname;
    userEmail = if (config.home.username == "masum-work") then "221108133+johnrtitor-work@users.noreply.github.com" else userSettings.gitemail;
    signing.key = if (config.home.username == "masum-work") then "157769ECD30424AF" else userSettings.gpgkey;
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
