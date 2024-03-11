# this config file is a wrapper to automatically configure vscode via a config file
{ ... }:
{
  home.file.".vscode/argv.json" = {
    source = ./vscode-argv.json;
    executable = false;
  };
}