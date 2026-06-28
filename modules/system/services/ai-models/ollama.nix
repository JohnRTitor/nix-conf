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
  rocmOverrideGfx = "10.3.0";
in
lib.mkIf enableOllama {
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
      # "lfm2.5:8b" # thinking

      ### CODING ###
      # https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF
      # CONTEXT sizes for coding
      # Low: 65536 (64K)
      # Max context: 131072 (128)
      "hf.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF:Q6_K" # BEST AND FAST AGENTIC CODING MODEL

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
}
