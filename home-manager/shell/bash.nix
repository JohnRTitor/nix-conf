{ ... }:
let
  inherit (import ./common.nix) commonSessionVariables commonRcExtra;
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra =
      commonRcExtra
      + ''
        # Custom bashrc go here, type below this line
      '';
    sessionVariables = commonSessionVariables // {
      # Add custom session variables for bash
    };

    shellAliases = {
      # set some aliases specific for bash
    };
  };
}
