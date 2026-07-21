{ pkgs, ... }: {

  home.file = {
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };

  home.file."Pictures/wallpapers" = {
    source = "${
      pkgs.fetchFromGitHub {
        name = "wallpaper-bank";
        owner = "LinuxBeginnings";
        repo = "Wallpaper-Bank";
        rev = "c14942d6b3ccd25d96b06521c6ff39a7f91c4599";
        sparseCheckout = [
          "wallpapers"
        ];
        hash = "sha256-1chTIPFpO4sz8XBHItWsftArd0X4pUikIY7mt0Vmy7g=";
      }
    }/wallpapers";

    recursive = true;
  };
}
