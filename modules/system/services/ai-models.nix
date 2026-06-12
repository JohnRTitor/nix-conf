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
  {
    services.ollama = {
      enable = true;
      # NOTE TO SELF: DO NOT RUN models greater than 12GB/14B as they will offload to CPU and RAM,
      # slowing down the model and system, sometimes causing crashes of the whole system
      # The models below are chosen to run on my hardware: RX 6700XT 12GB and Ryzen 5 7600 + 16GB DDR5
      loadModels = [
        ### GENERAL PURPOSE ###

        # https://ollama.com/library/gemma4
        "gemma4:12b" # general purpose, fast, vision

        # https://ollama.com/library/lfm2.5
        "lfm2.5:8b" # thinking

        ### UNCENSORED ###
        # NOTE: some models may be marked as "uncensored" but they'll still refuse some requests
        # Abiliterated models are trained to not refuse any requests and generate fully uncensored content
        # See https://huggingface.co/models?other=uncensored&library=gguf for Uncensored models
        # See https://huggingface.co/models?other=abliterated&library=gguf for abliterated models
        # Also see https://ollama.com/search?q=abliterated

        "hf.co/cognitivecomputations/Dolphin3.0-Llama3.1-8B-GGUF:Q8_0" # BEST OF THE ABLITERATED MODELS TESTED
        "huihui_ai/deepseek-r1-abliterated:14b" # (reasoning)

        ### SPECIAL PURPOSE ###
        # https://ollama.com/library/glm-ocr
        "glm-ocr" # OCR model, for extracting text from images/documents
      ];

      package = pkgs.ollama-rocm;

      # AMD does not officially have support for ROCM on RX 6700 XT (gfx1031)
      # However, the `AMD Radeon PRO W6800` or `RX 6800` are supported (gfx1030)
      # See https://github.com/ollama/ollama/blob/main/docs/gpu.md#amd-radeon and
      # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
      # Run `nix run nixpkgs#"rocmPackages.rocminfo" -- --run "rocminfo" | grep "gfx"` to know your gfx version
      # 10.3.0 is closest supported version to 10.3.1 so we are using that here
      rocmOverrideGfx = "10.3.0";
    };

    /*
      This is inferior to open-webui
      services.nextjs-ollama-llm-ui = {
        enable = true;
        hostname = "127.0.0.20";
      };
    */
  }

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
