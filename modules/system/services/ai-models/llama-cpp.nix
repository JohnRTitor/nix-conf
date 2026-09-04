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
  enableLlamaCPP = false;

  rocmOverrideGfx = "10.3.0";

  modelsPreset = {
    qwythos = {
      reasoning = "on";
      jinja = "on";

      hf-repo = "empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF";
      hf-file = "Qwythos-9B-Claude-Mythos-5-1M-MTP-Q6_K.gguf";

      temp = "0.6";
      top-p = "0.95";
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

lib.mkIf enableLlamaCPP {
  services.llama-cpp = {
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
      # sleep-idle-seconds = 10800; # 3h
      sleep-idle-seconds = 600; # 10 min

      # ── API ───────────────────────────────────────────────────────────
      jinja = true; # enable jinja2 chat template support

      # Enable reasoning/thinking mode
      reasoning = "on";

      # ── Concurrency ───────────────────────────────────────────────────
      # Number of parallel request slots. 1 = sequential (safest for VRAM).
      parallel = 1;

      # Save VRAM by quantised model cache
      # Available values: q8_0, q4_0, q4_1, iq4_nl, q5_0, q5_1
      # Lower ones have less accuracy, but also less memory
      cache-type-k = "q5_1";
      cache-type-v = "q5_1";

      n-gpu-layers = 999; # offload all layers to GPU

      # no-mmap = true; # avoid memory mapping to save host RAM
      mlock = true; # lock memory into RAM to avoid swapping
    };
  };

  systemd.services.llama-cpp.environment.HSA_OVERRIDE_GFX_VERSION = rocmOverrideGfx;
}
