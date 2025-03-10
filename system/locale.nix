# This conf file is used to configure locale, region and keymaps
{ systemSettings, ... }:
{
  # Set your time zone.
  time.timeZone = systemSettings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.additionalLocale;
    LC_IDENTIFICATION = systemSettings.additionalLocale;
    LC_MEASUREMENT = systemSettings.additionalLocale;
    LC_MONETARY = systemSettings.additionalLocale;
    LC_NAME = systemSettings.additionalLocale;
    LC_NUMERIC = systemSettings.additionalLocale;
    LC_PAPER = systemSettings.additionalLocale;
    LC_TELEPHONE = systemSettings.additionalLocale;
    LC_TIME = systemSettings.additionalLocale;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable touchpad support if laptop mode is enabled
  services.libinput.enable = systemSettings.laptop;
}
