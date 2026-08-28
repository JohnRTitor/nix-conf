{ ... }:
{
  services.syncthing = {
    enable = true;

    settings = {
      devices = {
        "pairadevice" = {
          id = "CABBVJC-F3PTR27-3AGHHLK-7YELIII-ELOZ2DA-LTUFHOS-6PQHHEV-SINEOQL";
        };
        # "pairadevice2" = {
        #   id = "TCJOWMW-7J5Y6VT-WUMFQKZ-KP27S7T-Y6HTJAU-AFQM4KL-Q6OQ6N7-RHKSHQ7";
        # };
        # "arunimadevice" = {
        #   id = "M62TYHV-PRY74RS-HLDCUN7-CXAERJE-J67LQGR-I2ODB4R-VZWXQ5B-WRAPSQF";
        # };
      };

      folders = {
        "PairaShared" = {
          path = "/home/masum/syncthing/Paira";
          devices = [
            "pairadevice"
            # "pairadevice2"
          ];
          order = "alphabetic";
          ignorePerms = false; # Enable file permission syncing
        };
        # "ArunimaShared" = {
        #   path = "/home/masum/syncthing/Arunima";
        #   devices = [ "arunimadevice" ];
        #   order = "alphabetic";
        #   ignorePerms = false; # Enable file permission syncing
        # };
      };
    };
  };
}
