{pkgs, ...}: {
  home.packages = with pkgs; [
    postman # Testing API
  ];

  xdg.desktopEntries = {
    mongodb-compass = {
      name = "MongoDB Compass";
      comment = "The MongoDB GUI";
      genericName = "MongoDB Compass";
      exec = "${pkgs.mongodb-compass}/bin/mongodb-compass --theme dark --ignore-additional-command-line-flags --enable-features=UseOzonePlatform --ozone-platform=x11 --password-store=gnome-libsecret %U";
      terminal = false;
      categories = [ "GNOME" "GTK" "Utility" ];
      mimeType = [ "x-scheme-handler/mongodb" "x-scheme-handler/mongodb+srv" ];
    };
  };
}
