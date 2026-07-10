# This conf file is used to configure locale, region and keymaps
{ config, ... }:
{
  # Set your time zone.
  time.timeZone = config.myOptions.systemSettings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = config.myOptions.systemSettings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = config.myOptions.systemSettings.additionalLocale;
    LC_IDENTIFICATION = config.myOptions.systemSettings.additionalLocale;
    LC_MEASUREMENT = config.myOptions.systemSettings.additionalLocale;
    LC_MONETARY = config.myOptions.systemSettings.additionalLocale;
    LC_NAME = config.myOptions.systemSettings.additionalLocale;
    LC_NUMERIC = config.myOptions.systemSettings.additionalLocale;
    LC_PAPER = config.myOptions.systemSettings.additionalLocale;
    LC_TELEPHONE = config.myOptions.systemSettings.additionalLocale;
    LC_TIME = config.myOptions.systemSettings.additionalLocale;
  };
}
