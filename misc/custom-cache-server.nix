# This config is used to define a custom cache server setting for the system
# It is useful when your build time is slow due to the network latency
# NOT USED BY DEFAULT
# ONLY KEPT FOR REFERENCE
# SINCE IT IS DANEROUS TO USE AND CAN LEAD TO SYSTEM BREAKAGE
{ userSettings, ... }:
{
  nix.settings = {
    # THIS IS REQUIRED BUT ALSO DANGEROUS
    # main user has access to nix store
    # THIS IS EQUIVALENT TO GIVING ROOT ACCESS TO THE MAIN USER
    trusted-users = [ "masum" ];

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      # default cache server
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  # DONT USE THIS UNLESS YOU KNOW WHAT YOU ARE DOING
  # socks5 proxy might speed up downloads in some cases
  # but most of the time it won't work leading to you not able to rebuild and fix your system
  # systemd.services.nix-daemon.environment.https_proxy = "socks5h://localhost:7891"; # socks5 proxy
  # systemd.services.nix-daemon.environment.https_proxy = "http://localhost:7890"; # https proxy
}
