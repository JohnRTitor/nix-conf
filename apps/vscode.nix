{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
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
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      ];
    })
  ];
}