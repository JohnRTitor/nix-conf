# This conf file is used to configure fonts
{ pkgs, ... }:
{
  # FONTS
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code # used in VS code
    noto-fonts-cjk-sans
    jetbrains-mono
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.inconsolata-lgc
    nerd-fonts.fira-code
    nerd-fonts.cousine
    roboto
    lohit-fonts.bengali # Bengali fonts
    # ultimate-oldschool-pc-font-pack
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    subpixel.rgba = "rgb"; # Subpixel rendering
    antialias = true;
    hinting.enable = true;
    useEmbeddedBitmaps = true; # for better rendering of Calibri like fonts
    cache32Bit = true;
  };

  # Console fonts
  console = {
    font = "ter-124b";
    keyMap = "us";
    packages = with pkgs; [
      terminus_font
    ];
  };
}
