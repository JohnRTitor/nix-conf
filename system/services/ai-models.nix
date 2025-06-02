{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    # NOTE TO SELF: do not run 27B (18GB) models, it will crash your system
    # cuz you only have 12GB of VRAM and 16 GB of RAM
    # with this setup, if a model does not fit in VRAM, it will offload to CPU
    # and use system RAM, which is slower and will lead to low performance
    loadModels = [
      "gemma3:12b" # general purpose - 8.1GB
      # "gemma3:12b-it-qat" - low speed than normal variant
      # "devstral:24b" - coding - 14GB, it offloads 23% to CPU, but tolerable
      "mychen76/qwen3_cline_roocode:14b" # coding - 9.3GB
      "dolphin-mistral:7b" # uncensored
    ];

    acceleration = "rocm";
    # 6700xt for ROCM is not officially supported by AMD
    # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
    # however, the `AMD Radeon PRO W6800` or `RX 6800` are supported (gfx1030)
    # and `RX 6700 XT` (gfx1031 - unsupported) is the closest to `gfx1030`, which is what I am using here.
    # you can get your gfx by `nix run nixpkgs#"rocmPackages.rocminfo" -- --run "rocminfo" | grep "gfx"`
    # it'll show multiple values if you have multiple GPUs configured
    rocmOverrideGfx = "10.3.0";
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };
  };

  # Web UI for Ollama
  services.nextjs-ollama-llm-ui = {
    enable = true;
    hostname = "127.0.0.20";
  };
}
