{
  services.easyeffects = {
    enable = true;

    # Community presets, can be found in https://github.com/wwmm/easyeffects/wiki/Community-Presets
    extraPresets = {
      # GentleDynamics - https://github.com/droidwayin/GentleDynamics/blob/main/GentleDynamics.json
      base = builtins.fromJSON (builtins.readFile ./presets/base.json);

      # EasyEffects - https://github.com/p-chan5/EasyPulse/blob/main/p-chan5/hifi-min.json
      headphones = builtins.fromJSON (builtins.readFile ./presets/headphones.json);

      # Microphone with NR - https://gist.github.com/jtrv/47542c8be6345951802eebcf9dc7da31
      mic = builtins.fromJSON (builtins.readFile ./presets/mic.json);
    };
  };
}
