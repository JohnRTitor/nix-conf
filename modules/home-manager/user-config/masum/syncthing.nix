{ ... }:
{
  services.syncthing = {
    enable = true;

    settings = {
      devices = {
        "pairadevice" = {
          id = "V7GVDS2-R3XUD6U-6RFMWTY-ZEULLGG-TUZ2D5N-D57UZSQ-QEFBJWJ-B6V76QL";
        };
        "arunimadevice" = {
          id = "M62TYHV-PRY74RS-HLDCUN7-CXAERJE-J67LQGR-I2ODB4R-VZWXQ5B-WRAPSQF";
        };
      };
      
      folders = {
        "PairaShared" = {
          path = "/home/masum/syncthing/Paira";
          devices = [ "pairadevice" ];
          order = "alphabetic";
          ignorePerms = false; # Enable file permission syncing
        };
        "ArunimaShared" = {
          path = "/home/masum/syncthing/Arunima";
          devices = [ "arunimadevice" ];
          order = "alphabetic";
          ignorePerms = false; # Enable file permission syncing
        };
      };
    };
  };
}
