{pkgs, ...}: {
  home.packages = with pkgs; [
    deluge # Torrent client
  ];
}
