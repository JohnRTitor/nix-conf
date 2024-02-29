# This conf file is used to configure fonts
{ pkgs, ... }:
{
  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk
    jetbrains-mono
    font-awesome
    (nerdfonts.override {fonts = [ "JetBrainsMono" "InconsolataLGC" ];})
  ];
}