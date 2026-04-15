{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.myOptions.programsSettings.fileManager == "thunar") {
  home.file.".config/xfce4/helpers.rc".text = ''
    WebBrowser=google-chrome-stable
    Editor=code
    TerminalEmulator=${config.myOptions.programsSettings.terminal}
    TerminalEmulatorDismissed=true
  '';
}
