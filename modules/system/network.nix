# Configure networking, firewall, proxy, etc.
{
  lib,
  servicesSettings,
  ...
}:
{
  # Enable WIFI, Ethernet, ...
  networking.networkmanager.enable = true;

  /*
    networking.networkmanager.wifi.backend = "iwd"; # newer backend

    services.resolved.enable = true; # enable systemd-resolved
    services.resolved.dnssec = "allow-downgrade"; # enable if available
    services.resolved.dnsovertls = "opportunistic"; # enable if available

    # DNS servers
    networking.networkmanager.insertNameservers = [
      "1.1.1.1" # Cloudflare DNS
      "1.0.0.1"
    ];
  */

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  boot.kernel.sysctl = {
    # Low Latency Queueing & Congestion Control
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Handle Rapid Connection Bursts
    "net.ipv4.tcp_max_syn_backlog" = 2048;
  };

  networking.firewall = {
    enable = true;

    # Open ports for local web development servers and frameworks (Next.js, Vite, FastAPI, HTTP/S)
    # This allows access from the local network, ie, another PC or mobile device
    allowedTCPPortRanges = [
      {
        from = 3000;
        to = 3010;
      }
    ];

    allowedTCPPorts = [
      5173
      8080
    ];
  };

  # New Firewall backend
  networking.nftables.enable = true;
}
