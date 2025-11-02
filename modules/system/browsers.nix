# This config file is used to configure browsers
{
  self,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  # Zen-browser
  programs.firefox = {
    enable = true;
    package = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    policies = {
      DontCheckDefaultBrowser = true; # disable the annoying popup at startup
      HardwareAcceleration = true;
    };
  };

  environment.systemPackages =
    (with pkgs; [
      # tor-browser
    ])
    ++ [
      self.packages.${pkgs.stdenv.hostPlatform.system}.google-chrome_repackaged
    ];
}
