{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deluge # Torrent client

    ## PERSONAL ENJOYMENT ##
    # ani-cli # watch anime in terminal!

    materialgram # Good looking material themed telegram client
    fluffychat # Matrix client
    gajim # XMPP client
    /*
      (element-desktop.override { # Matrix client
        # if keyring does not work, try either "libsecret" or "gnome"
        commandLineArgs = ''--password-store=gnome-libsecret'';
      })
    */
    
    postman
  ];
}
