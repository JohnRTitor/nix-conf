# this config file is a wrapper to automatically configure vscode via a config file
{ pkgs, pkgs-vscode-extensions, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    # Since not all extensions are provided via nixpkgs,
    # We are using a vscode marketplace flake
    # But we are still allowing extensions to be installed from VS code GUI
    # disabling mutableExtensionsDir will mess up things
    extensions = with pkgs-vscode-extensions.vscode-marketplace; [
      bbenoist.nix # Nix language support
      ms-python.python # Python language support
      ms-vscode.cpptools # C/C++ language support
      ms-vscode.cpptools-extension-pack # C/C++ extension pack
      tamasfe.even-better-toml # TOML language support
      davidanson.vscode-markdownlint # Markdown Linting

      github.copilot # GitHub Copilot
      github.copilot-chat # GitHub Copilot Chat
      github.codespaces # GitHub Codespaces
      github.vscode-pull-request-github # GitHub Pull Requests
      github.vscode-github-actions # GitHub Actions
      donjayamanne.githistory # Git History

      ms-azuretools.vscode-docker # Docker
      ms-vscode-remote.remote-ssh # Remote SSH

      rolandgreim.sharecode # Pastebin/Gist support

      # dracula-theme.theme-dracula # Dracula theme
      # enkia.tokyo-night # Tokyo Night theme
      robbowen.synthwave-vscode # SynthWave '84 theme
      pkief.material-icon-theme # Material Icon Theme
      pkief.material-product-icons # Material Product Icons
    ];
    userSettings = {
      "workbench.colorTheme" = "SynthWave '84";
      # "Tokyo Night"; # "Dracula"; # "Default Dark Modern"; # ^ Set the default theme
      "workbench.productIconTheme" = "material-product-icons"; # Set the product icon theme
      "workbench.iconTheme" = "material-icon-theme"; # Set the file icon theme

      "git.confirmSync" = false; # Do not ask for confirmation when syncing
      "git.autofetch" = true; # Periodically fetch from remotes
      "editor.fontFamily" = "'Fira Code Nerd Font', 'Inconsolata LGC Nerd Font', 'Droid Sans Mono', 'monospace'";
      # fonts are defined in the ../../fonts.nix file
      "editor.fontLigatures" =  true;
      "terminal.integrated.fontFamily" = "'JetBrains Nerd Font', 'Inconsolata LGC Nerd Font', monospace";
    };
  };

  # Wrapper to configure which arguments vscode should be started with
  home.file.".vscode/argv.json" = {
    source = ./vscode-argv.json5;
    executable = false;
  };
}
