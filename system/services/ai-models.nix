{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    loadModels = [
      "codellama"
      "devstral:24b"
      "dolphin3:8b"
    ];
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
  };
}
