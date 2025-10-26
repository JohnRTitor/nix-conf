{ pkgs, ... }:
{
  ## Work profile packages ##
  /*
  home.packages = with pkgs; [
    postman # Testing API
    prettier

    wf-recorder # Record screen (with audio)
  ];

  xdg.desktopEntries.mongodb-compass = {
    name = "MongoDB Compass";
    comment = "The MongoDB GUI";
    genericName = "MongoDB Compass";
    exec = "${pkgs.mongodb-compass}/bin/mongodb-compass --theme dark --ignore-additional-command-line-flags --enable-features=UseOzonePlatform --ozone-platform=x11 --password-store=gnome-libsecret %U";
    icon = "${pkgs.mongodb-compass}/share/pixmaps/mongodb-compass.png";
    terminal = false;
    categories = [
      "GNOME"
      "GTK"
      "Utility"
    ];
    mimeType = [
      "x-scheme-handler/mongodb"
      "x-scheme-handler/mongodb+srv"
    ];
  };

  xdg.desktopEntries.gitkraken = {
    name = "GitKraken Desktop";
    icon = "${pkgs.gitkraken}/share/gitkraken/gitkraken.png";
    comment = "Unleash your repo";
    genericName = "Git Client";
    exec = "${pkgs.gitkraken}/bin/gitkraken --enable-features=UseOzonePlatform --ozone-platform=x11 --password-store=gnome-libsecret %U";
    terminal = false;
    categories = [ "Development" ];
    settings = {
      Version = "1.4";
    };
  };
  */
}
