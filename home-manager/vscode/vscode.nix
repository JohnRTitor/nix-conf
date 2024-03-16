# this config file is a wrapper to automatically configure vscode via a config file
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix # Nix language support
      ms-python.python # Python language support
      ms-vscode.cpptools # C/C++ language support
      tamasfe.even-better-toml # TOML language support

      dracula-theme.theme-dracula # Dracula theme

      github.copilot # GitHub Copilot
      github.copilot-chat # GitHub Copilot Chat
      github.codespaces # GitHub Codespaces
      github.vscode-pull-request-github # GitHub Pull Requests

      ms-azuretools.vscode-docker # Docker
      ms-vscode-remote.remote-ssh # Remote SSH
    ];
    userSettings = {
      "git.confirmSync" = false; # Do not ask for confirmation when syncing
      "git.autofetch" = true; # Periodically fetch from remotes
      "editor.fontFamily" = "'Fira Code', 'Hack Nerd Font', 'InconsolataLGC Nerd Font', 'Droid Sans Mono', 'monospace'";
      "editor.fontLigatures" =  true;
      "terminal.integrated.fontFamily" = "'Fira Code SemiBold', 'Hack Nerd Font', 'InconsolataLGC Nerd Font'";

    };
  };

  # Wrapper to configure which arguments vscode should be started with
  home.file.".vscode/argv.json" = {
    source = ./vscode-argv.json5;
    executable = false;
  };
}
