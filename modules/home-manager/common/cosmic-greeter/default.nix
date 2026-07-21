{
  config,
  pkgs,
  lib,
  ...
}:
let
  bg-image = if (config.home.username == "masum-work") then ./bg-image2.png else ./bg-image1.png;
in
lib.mkIf (config.myOptions.programsSettings.displayManager == "cosmic-greeter") {
  # The following config sets a background image for cosmic-greeter, for this user
  # Not that background images and themes are user specific, and will change depending on the
  # user selected in the greeter
  xdg.configFile."cosmic/com.system76.CosmicBackground/v1/all".text = ''
    (
      filter_by_theme: false,
      filter_method: Lanczos,
      output: "all",
      rotation_frequency: 300,
      sampling_method: Alphanumeric,
      scaling_mode: Zoom,
      source: Path("${bg-image}"),
    )
  '';

  xdg.configFile."cosmic/com.system76.CosmicBackground/v1/same-on-all".text = "true";

  # Needed, else cosmic-greeter won't pick it up
  xdg.stateFile."cosmic/com.system76.CosmicBackground/v1/wallpapers".text = ''
    [
      ("HDMI-A-1", Path("${bg-image}")),
    ]
  '';
}
