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
  enableOllama = true;
  enableLlamaCPP = false;
  enableOdysseus = true;
  enableOpenWebUI = false;

  rocmOverrideGfx = "10.3.0";
in
lib.mkMerge [
  (lib.mkIf enableOllama {
    services.ollama = {
      enable = true;

      # NOTE: vulkan package performs better on average
      # package = pkgs.ollama-rocm;
      package = pkgs.ollama-vulkan;

      # NOTE TO SELF: DO NOT RUN models greater than 12GB/14B as they will offload to CPU and RAM,
      # slowing down the model and system, sometimes causing crashes of the whole system
      # The models below are chosen to run on my hardware: RX 6700XT 12GB and Ryzen 5 7600 + 16GB DDR5
      loadModels = [
        ### GENERAL PURPOSE ###

        # https://ollama.com/library/gemma4
        "gemma4:12b" # general purpose, fast, vision

        # https://ollama.com/library/lfm2.5
        "lfm2.5:8b" # thinking

        ### CODING ###
        # https://huggingface.co/collections/Jackrong/qwopus-coder
        # CONTEXT sizes for coding
        # Low: 65536 (64K)
        # Max context: 131072 (128)
        "hf.co/Jackrong/Qwopus3.5-9B-Coder-GGUF:Q6_K"

        ### UNCENSORED ###
        # NOTE: some models may be marked as "uncensored" but they'll still refuse some requests
        # Abiliterated models are trained to not refuse any requests and generate fully uncensored content
        # See https://huggingface.co/models?other=uncensored&library=gguf for Uncensored models
        # See https://huggingface.co/models?other=abliterated&library=gguf for abliterated models
        # Also see https://ollama.com/search?q=abliterated

        # https://huggingface.co/HauhauCS/models
        # CONTEXT sizes for coding
        # Low: 65536 (64K)
        # Max context: 131072 (128)
        "hf.co/HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive:Q6_K" # (reasoning) BEST ABLITERATED MODEL

        ### SPECIAL PURPOSE ###
        # https://ollama.com/library/glm-ocr
        "glm-ocr" # OCR model, for extracting text from images/documents
      ];

      # AMD does not officially have support for ROCM on RX 6700 XT (gfx1031)
      # However, the `AMD Radeon PRO W6800` or `RX 6800` are supported (gfx1030)
      # See https://github.com/ollama/ollama/blob/main/docs/gpu.md#amd-radeon and
      # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
      # Run `nix run nixpkgs#"rocmPackages.rocminfo" -- --run "rocminfo" | grep "gfx"` to know your gfx version
      # 10.3.0 is closest supported version to 10.3.1 so we are using that here
      # rocmOverrideGfx = "10.3.0"; # Not needed if vulkan is used
    };

    # cap context length, this will force context length
    # better to set it in zed instead
    # services.ollama.environmentVariables.OLLAMA_CONTEXT_LENGTH = "131072";
    # environment.sessionVariables.OLLAMA_CONTEXT_LENGTH = "131072";
  })

  (lib.mkIf enableLlamaCPP {
    services.llama-cpp =
      let
        modelsPreset = {
          qwen = {
            reasoning = "on";
            jinja = "on";

            hf-repo = "HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive";
            hf-file = "Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q6_K.gguf";

            temp = "0.7";
            top-p = "0.8";
            top-k = "20";
          };

          # gemma-4-E2B = {
          #   hf-repo = "unsloth/gemma-4-E2B-it-GGUF";
          #   hf-file = "gemma-4-E2B-it-UD-Q5_K_XL.gguf";
          #   alias = "unsloth/gemma-4-E2B-it-GGUF";
          #   fit = "on";
          #   seed = "3407";
          #   temp = "1.0";
          #   top-p = "0.95";
          #   min-p = "0.01";
          #   top-k = "40";
          #   jinja = "on";
          # };

          # gemma-4-E4B = {
          #   hf-repo = "unsloth/gemma-4-E4B-it-GGUF";
          #   hf-file = "gemma-4-E4B-it-UD-Q8_K_XL.gguf";
          #   alias = "unsloth/gemma-4-E4B";
          #   fit = "on";
          #   temp = "1.0";
          #   top-p = "0.95";
          #   min-p = "0.01";
          #   top-k = "40";
          #   jinja = "on";
          # };

          # gemma-4-26B-A4B = {
          #   hf-repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
          #   hf-file = "gemma-4-26B-A4B-it-UD-IQ2_XXS.gguf";
          #   alias = "unsloth/gemma-4-26B-A4B";
          #   fit = "on";
          #   temp = "1.0";
          #   top-p = "0.95";
          #   min-p = "0.01";
          #   top-k = "64";
          #   jinja = "on";
          # };

          # "deepseek-r1-8b" = {
          #   hf-repo = "unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF";
          #   hf-file = "DeepSeek-R1-0528-Qwen3-8B-Q8_0.gguf";
          #   alias = "unsloth/DeepSeek-R1-0528-Qwen3-8B";
          #   fit = "on";
          #   temp = "0.6";
          #   top-p = "0.95";
          #   jinja = "on";
          # };

          # "qwen3.6-35b-a3b" = {
          #   hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF";
          #   hf-file = "Qwen3.6-35B-A3B-UD-IQ2_XXS.gguf";
          #   alias = "unsloth/Qwen3-Coder-30B-A3B";
          #   fit = "on";
          #   temp = "0.6";
          #   top-p = "0.8";
          #   top-k = "20";
          #   min-p = "0.0";
          #   jinja = "on";
          # };

          # "qwen3-coder-30b-a3b" = {
          #   hf-repo = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF";
          #   hf-file = "Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS.gguf";
          #   alias = "unsloth/Qwen3-Coder-30B-A3B";
          #   fit = "on";
          #   temp = "0.7";
          #   top-p = "0.8";
          #   top-k = "20";
          #   jinja = "on";
          # };

          # gemma-4-31B = {
          #   hf-repo = "unsloth/gemma-4-31B-it-GGUF:UD-IQ2_XXS";
          #   hf-file = "gemma-4-31B-it-UD-IQ2_XXS.gguf";
          #   alias = "unsloth/gemma-4-31B-it-GGUF";
          #   temp = "1.0";
          #   top-p = "0.95";
          #   min-p = "0.01";
          #   top-k = "64";
          #   jinja = "on";
          # };
        };

        modelsPresetFile =
          if (modelsPreset != null) then
            pkgs.writeText "llama-models-preset.ini" (lib.generators.toINI { } modelsPreset)
          else
            null;
      in
      {
        enable = true;

        # NOTE: vulkan package performs better on average
        package = pkgs.llama-cpp-vulkan;
        # package = pkgs.llama-cpp-rocm;

        openFirewall = true;

        settings.models-dir = "/var/lib/ai-models";
        settings.models-preset = modelsPresetFile;

        # Force single model mode
        # settings.model = "/var/lib/ai-models/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q6_K.gguf";
        # settings.chat-template-file = "/var/lib/ai-models/qwen-3.5.jinja";

        settings = {
          # host = "0.0.0.0";
          port = 8888;

          # Router server: limit concurrent loaded models to save VRAM
          models-max = 1; # Load 1 model at a time, auto-swap on demand

          # Enable automatic model loading/unloading based on requests
          models-autoload = true;

          # ── Context window ────────────────────────────────────────────────
          # 262144 = 256k tokens.
          ctx-size = 131072;

          # ── Idle model unload ─────────────────────────────────────────────
          # Unload model weights from GPU VRAM after 3h of no requests.
          sleep-idle-seconds = 10800; # 3h

          # ── API ───────────────────────────────────────────────────────────
          jinja = true; # enable jinja2 chat template support

          # Enable reasoning/thinking mode
          reasoning = "on";

          # ── Concurrency ───────────────────────────────────────────────────
          # Number of parallel request slots. 1 = sequential (safest for VRAM).
          parallel = 1;

          # cache-type-k = "q4_0"; # quantised KV cache (Q4_0) to save VRAM
          # cache-type-v = "q4_0"; # quantised KV cache (Q4_0) to save VRAM

          n-gpu-layers = 999; # offload all layers to GPU

          # no-mmap = true; # avoid memory mapping to save host RAM
          mlock = true; # lock memory into RAM to avoid swapping
        };
      };

    systemd.services.llama-cpp.environment.HSA_OVERRIDE_GFX_VERSION = rocmOverrideGfx;
  })

  {
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
