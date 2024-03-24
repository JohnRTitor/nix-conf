# This conf file is used to configure locale, region and keymaps
{ systemSettings, ... }:

{
  # Set your time zone.
  time.timeZone = systemSettings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.localeoverride;
    LC_IDENTIFICATION = systemSettings.localeoverride;
    LC_MEASUREMENT = systemSettings.localeoverride;
    LC_MONETARY = systemSettings.localeoverride;
    LC_NAME = systemSettings.localeoverride;
    LC_NUMERIC = systemSettings.localeoverride;
    LC_PAPER = systemSettings.localeoverride;
    LC_TELEPHONE = systemSettings.localeoverride;
    LC_TIME = systemSettings.localeoverride;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";
  
  # Enable touchpad support if laptop mode is enabled
  services.xserver.libinput.enable = systemSettings.laptop;
}