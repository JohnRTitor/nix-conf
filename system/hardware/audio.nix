# This conf file is used to configure audio and sound related settings
{ ... }:
{
  # Enable sound with pipewire, don't enable pulseaudio.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true; # alsa support
    alsa.support32Bit = true;
    pulse.enable = true; # pulseaudio compat
    jack.enable = true; # enable jack audio
  };
  # Enable rtkit for real-time scheduling, required for pipewire
  security.rtkit.enable = true;

  # Enable low latency
  services.pipewire.extraConfig.pipewire = {
    "92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 512;
      };
    };
  };

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
    { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
    { domain = "@audio"; item = "nofile" ; type = "hard"; value = "524288"    ; }
  ];
}