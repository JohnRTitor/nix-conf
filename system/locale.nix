# This conf file is used to configure locale, region and keymaps
{ systemSettings, ... }:

{
  # Set your time zone.
  time.timeZone = systemSettings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.localeoverride;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.localeoverride;
    LC_TELEPHONE = systemSettings.localeoverride;
    LC_TIME = systemSettings.localeoverride;
  };

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_IN.UTF-8/UTF-8"
  ];

  services = {
    xserver = {
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
    };
  };
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

}