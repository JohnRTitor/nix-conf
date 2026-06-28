{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-master,
  ...
}:

let
  ## PREFS ##
  enableOdysseus = true;
  enableOpenWebUI = false;

in
lib.mkMerge [
  (lib.mkIf enableOdysseus {
    services.odysseus = {
      enable = true;
      # Add admin password, admin user here
      # https://github.com/pewdiepie-archdaemon/odysseus/blob/dev/.env.example
      environmentFile = "/var/lib/odysseus/odysseus-env";
      # This maps to localhost on this PC
      # and this PC's private IP on the local network
      host = "0.0.0.0";
      port = 8000;

      extraPythonPackages = ps: [
        # For viewing PDFs
        ps.pymupdf
        ps.pymupdf4llm
      ];

      llamaCpp.enable = true;
    };

    networking.firewall.allowedTCPPorts = [ 8000 ];

    networking.hosts."127.0.0.1" = [
      "odysseus.local"
    ];
  })

  (lib.mkIf enableOpenWebUI {
    # Creates a Web UI for running models via Ollama at http://127.0.0.20:3000
    services.open-webui = {
      enable = true;
      # package = pkgs-master.open-webui;
      host = "0.0.0.0";
      port = 9000;
    };

    networking.firewall.allowedTCPPorts = [ 9000 ];

    networking.hosts."127.0.0.1" = [
      "ollama.local"
    ];
  })
]
