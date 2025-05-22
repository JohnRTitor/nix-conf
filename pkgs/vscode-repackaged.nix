# This file is specifically for overriding desktop item of VSCode
# to make it work with my encrypted SSH keys by passing environment variables
{
  vscode,
  makeDesktopItem,
}:
let
  executableName = "code";
  longName = "Visual Studio Code";
  shortName = "Code";
  envVars = "env SSH_AUTH_SOCK=/run/user/1001/gnupg/S.gpg-agent.ssh";
in
(
  (vscode.override {
    # if keyring does not work, try either "libsecret" or "gnome"
    commandLineArgs = ''--password-store=gnome-libsecret'';
  }).overrideAttrs
  {
    desktopItems = [
      (makeDesktopItem {
        name = executableName;
        desktopName = longName;
        comment = "Code Editing. Redefined.";
        genericName = "Text Editor";
        exec = "${envVars} ${executableName} %F";
        icon = "vs${executableName}";
        startupNotify = true;
        startupWMClass = shortName;
        categories = [
          "Utility"
          "TextEditor"
          "Development"
          "IDE"
        ];
        keywords = [ "vscode" ];
        actions.new-empty-window = {
          name = "New Empty Window";
          exec = "${executableName} --new-window %F";
          icon = "vs${executableName}";
        };
      })
      (makeDesktopItem {
        name = executableName + "-url-handler";
        desktopName = longName + " - URL Handler";
        comment = "Code Editing. Redefined.";
        genericName = "Text Editor";
        exec = envVars + executableName + " --open-url %U";
        icon = "vs${executableName}";
        startupNotify = true;
        categories = [
          "Utility"
          "TextEditor"
          "Development"
          "IDE"
        ];
        mimeTypes = [ "x-scheme-handler/vs${executableName}" ];
        keywords = [ "vscode" ];
        noDisplay = true;
      })
    ];
  }
)
