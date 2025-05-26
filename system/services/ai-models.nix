{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    loadModels = [
      "codellama"
      "devstral:24b"
    ];
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
  };
}
