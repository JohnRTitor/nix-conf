# this config file is a wrapper to automatically configure vscode via a config file
{
  config,
  osConfig,
  pkgs,
  self,
  inputs,
  ...
}:
let
  # extract package pname for each package in the list of all installed packages, then put them in a list
  packagesList = map (x: x.pname) (config.home.packages ++ osConfig.environment.systemPackages);
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      # if keyring does not work, try either "libsecret" or "gnome"
      commandLineArgs = "--password-store=gnome-libsecret";
    };
  };

  # Default profile
  programs.vscode.profiles.default = {
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    # Since not all extensions are provided via nixpkgs,
    # We are using a vscode marketplace flake
    # But we are still allowing extensions to be installed from VS code GUI
    # disabling mutableExtensionsDir will mess up things
    extensions =
      (with (pkgs.forVSCodeVersion config.programs.vscode.package.version).vscode-marketplace; [
        ## Language support ##
        jnoortheen.nix-ide # Nix language support
        # ms-python.python # Python language support
        # ms-vscode.cpptools-extension-pack # C/C++ extension pack
        tamasfe.even-better-toml # TOML language support
        # bmewburn.vscode-intelephense-client # PHP language support
        bradlc.vscode-tailwindcss # Tailwind CSS IntelliSense

        ## Linters ##
        esbenp.prettier-vscode # Prettier code formatter
        davidanson.vscode-markdownlint # Markdown Linting

        ## GIT Tools ##
        github.copilot # GitHub Copilot
        github.codespaces # GitHub Codespaces
        github.vscode-github-actions # GitHub Actions
        donjayamanne.githistory # Git History
        # eamodio.gitlens # GitLens

        ## MISCELLANEOUS ##
        ms-azuretools.vscode-docker # Docker
        ms-vscode-remote.remote-ssh # Remote SSH

        rolandgreim.sharecode # Pastebin/Gist support
        # ritwickdey.liveserver # launch local html web server
        mkhl.direnv # direnv support
        oderwat.indent-rainbow # colorful indentation
        # arrterian.nix-env-selector # not needed at the moment

        ## THEMING ##
        # dracula-theme.theme-dracula # Dracula theme
        # enkia.tokyo-night # Tokyo Night theme
        robbowen.synthwave-vscode # SynthWave '84 theme
        pkief.material-icon-theme # Material Icon Theme
        pkief.material-product-icons # Material Product Icons
      ])
      ++ (with pkgs.vscode-marketplace-release; [
        github.copilot-chat # GitHub Copilot Chat, need the release version
      ])
      ++ (with pkgs.vscode-marketplace; [
        ms-vscode-remote.remote-containers # Dev Containers

        github.vscode-pull-request-github # GitHub Pull Requests
      ])
      ++ (with pkgs.vscode-extensions; [
        # ms-vscode.cpptools # C/C++ language support, only available via nixpkgs
      ]);
    userSettings = {
      "workbench.colorTheme" = "SynthWave '84";
      # "Tokyo Night"; # "Dracula"; # "Default Dark Modern"; # ^ Set the default theme
      "workbench.productIconTheme" = "material-product-icons"; # Set the product icon theme
      "workbench.iconTheme" = "material-icon-theme"; # Set the file icon theme

      "editor.cursorBlinking" = "expand";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "files.autoSave" = "afterDelay";

      "git.confirmSync" = false; # Do not ask for confirmation when syncing
      "git.autofetch" = true; # Periodically fetch from remotes
      "editor.fontFamily" =
        "'Fira Code Nerd Font', 'Inconsolata LGC Nerd Font', 'Droid Sans Mono', 'monospace'";
      # fonts are defined in the ../../fonts.nix file
      "editor.fontLigatures" = true;
      "terminal.integrated.fontFamily" = "'JetBrains Nerd Font', 'Inconsolata LGC Nerd Font', monospace";

      "direnv.restart.automatic" = true; # Automatically restart direnv if .envrc changes
      "nix.enableLanguageServer" = true;

      # Check if nixd or nil is installed and set the server accordingly
      "nix.serverPath" =
        if (builtins.elem "nixd" packagesList) then
          "nixd"
        else if (builtins.elem "nil" packagesList) then
          "nil"
        else
          null;

      "dev.containers.dockerPath" = "podman"; # Use podman as the docker path

      ## Formatter Config ##
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[markdown]"."editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
  };
}
