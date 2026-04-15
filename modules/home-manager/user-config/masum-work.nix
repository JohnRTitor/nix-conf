{ pkgs, ... }:
{
  imports = [
    ../common
    # ../common/vscode.nix
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      # if keyring does not work, try either "libsecret" or "gnome"
      commandLineArgs = "--password-store=gnome-libsecret";
    };
  };

  home.shellAliases = {
    read-notes = "bat ~/Dev-Environment/notes.txt";
    write-notes = "nano ~/Dev-Environment/notes.txt";
  };
}
