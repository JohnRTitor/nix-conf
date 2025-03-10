# This conf file is used to configure audio and sound related settings
{ ... }:
{
  # Enable sound via pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable rtkit for real-time scheduling, required for pipewire
  security.rtkit.enable = true;

  /*
    # Enable low latency
    services.pipewire.extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 512;
      };
    };

    # For those apps still using the pulseaudio API
    services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
      "context.properties" = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {};
        }
      ];
      "pulse.properties" = {
        "pulse.min.req" = "32/48000";
        "pulse.default.req" = "32/48000";
        "pulse.max.req" = "32/48000";
        "pulse.min.quantum" = "32/48000";
        "pulse.max.quantum" = "32/48000";
      };
      "stream.properties" = {
        "node.latency" = "32/48000";
        "resample.quality" = 1;
      };
    };
  */
}
