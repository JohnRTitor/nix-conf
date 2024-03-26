# This conf file is used to configure fonts
{ pkgs, ... }:
{
  # FONTS
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code # used in VS code
    noto-fonts-cjk
    jetbrains-mono
    font-awesome
    (nerdfonts.override { # Nerd fonts, must for icons
      fonts = [
        "JetBrainsMono" # used in VS code terminal
        "InconsolataLGC" # used in Alacritty, VS code
        "FiraCode" # used in VS code
      ];
    })
    roboto
    lohit-fonts.bengali # Bengali fonts
  ];
  fonts.fontDir.enable = true;
  fonts.fontconfig.subpixel.rgba = "rgb"; # Subpixel rendering
}