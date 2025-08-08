{pkgs, ...}: {
  home.packages = with pkgs; [
    deluge # Torrent client

    ## PERSONAL ENJOYMENT ##
    # ani-cli # watch anime in terminal!
  ];
}
