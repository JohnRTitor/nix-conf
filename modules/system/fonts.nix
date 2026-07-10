# This conf file is used to configure fonts
{ pkgs, ... }:
{
  # FONTS and ICONS
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    lohit-fonts.bengali # Bengali fonts

    # Needed for wlogout and several Waybar themes (Jerry, ddubs, jak-oglo, etc.)
    # font-awesome

    jetbrains-mono

    # Only used in Kitty terminal (modules/home-manager/common/terminals/kitty.nix)
    maple-mono.NF

    # Only used in Waybar TheBlackDon theme
    # nerd-fonts.iosevka-term

    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji

    # Only used in Waybar jak-oglo-simple theme
    # roboto
    # roboto-mono
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
