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