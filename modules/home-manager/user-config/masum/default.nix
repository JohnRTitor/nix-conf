{ pkgs, ... }:
{
  imports = [
    ../../common
    # ../../common/vscode.nix
    ./syncthing.nix
  ];
  
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      # if keyring does not work, try either "libsecret" or "gnome"
      commandLineArgs = ''--password-store=gnome-libsecret'';
    };
  };
  
  home.packages = with pkgs; [
    (antigravity.override {
      # if keyring does not work, try either "libsecret" or "gnome"
      commandLineArgs = ''--password-store=gnome-libsecret'';
    })
  ];
}
