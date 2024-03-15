# This config is used to define a custom cache server setting for the system
# It is useful when your build time is slow due to the network latency
{ userSettings, ... }:
{
  nix.settings = {
    # main user has access to modify trusted cache server
    trusted-users = [ userSettings.username ];

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      
      # default cache server
      "https://cache.nixos.org"
      # nix community's cache server
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  # Use socks5 proxy for nix-daemon
  # To accelerate downloads
  systemd.services.nix-daemon.environment = {
    # socks5h means that the hostname is resolved by the SOCKS server
    https_proxy = "socks5h://localhost:7891";
    # https_proxy = "http://localhost:7890"; # or use http protocol instead of socks5
  };
}