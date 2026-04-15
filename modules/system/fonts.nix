# This conf file is used to configure fonts
{ pkgs, ... }:
{
  # FONTS and ICONS
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    lohit-fonts.bengali # Bengali fonts

    dejavu_fonts
    fira-code
    fira-code-symbols
    font-awesome
    hackgen-nf-font
    ibm-plex
    inter
    jetbrains-mono
    material-icons
    maple-mono.NF
    minecraftia
    nerd-fonts.im-writing
    nerd-fonts.blex-mono
    nerd-fonts.iosevka-term
    nerd-fonts.lilex
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji
    powerline-fonts
    roboto
    roboto-mono
    symbola
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
