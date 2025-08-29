{ pkgs, ... }:
{
  home.packages = [ pkgs.thunar ];
  home.file.".config/xfce4/helpers.rc".text = ''
    WebBrowser=google-chrome-stable
    Editor=code
    TerminalEmulator=kitty
    TerminalEmulatorDismissed=true
  '';
}
