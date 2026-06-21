{
  # initial commands to run for all shells
  commonRcExtra = ''
    # Custom extraRc from home-manager/shell.nix

    execmd() { echo "Executing: $@" && "$@" ; } # wrapper to print command before executing it

    getpkgs() { # Construct a getpkgs wrapper of nom shell
      local command="env NIXPKGS_ALLOW_UNFREE=1 nom shell --impure"
      for arg in "$@"; do # loop through all package names given as args
        command+=" nixpkgs#$arg"
      done
      eval "execmd $command"
    } # now you can run `getpkgs package1 package2 package3` to get a nix shell

    gettemp() { # Create a temporary directory and open a subshell, the directory is cleaned up on exit
      local tmpdir
      tmpdir=$(mktemp -d)
      pushd "$tmpdir" > /dev/null # Change to the temporary directory

      # Identify the current shell from /proc/$$/cmdline
      shell=$(cat /proc/$$/cmdline | tr -d '\0')

      # Print a red warning message
      echo -e "\033[0;31mWarning: Everything you do within this directory will be cleaned up on exit\033[0m"
      echo -e "Temporary directory: \033[0;34m$tmpdir\033[0m" # in blue
      "$shell"                 # Open a subshell

      popd > /dev/null         # Return to the original directory upon exit
      rm -rf "$tmpdir"         # Clean up the temporary directory, using trap for this is buggy
    }
  '';

  # Define common aliases which would apply to all shells
  commonAliases = {
    check-flake = "execmd nix flake check";
    update-flake = "execmd nix flake update";
    # update-flake-input = "nix flake lock --update-input";
    # rebuild = "execmd sudo nixos-rebuild switch";
    # garbage-collect = "execmd sudo nix-collect-garbage -d";
    fix-store = "execmd sudo nix-store --verify --check-contents --repair";
    runpkg = "execmd nix run";
    getpkgpath = "nix build --print-out-paths";
    # cfastfetch is just an alias to run compact fastfetch
    cfastfetch = "fastfetch --config ~/.config/fastfetch/config-compact.jsonc";
    # alias for running ollama llm, see ai-models.nix for configured models
    ask = "execmd ollama run lfm2.5:8b";
  };

  # Define common session variables which would apply to all shells
  commonSessionVariables = {
    # Binds GPG to current tty
    GPG_TTY = "$(tty)";
    # Add custom bin directories to the PATH
    PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
  };
}
