{ ... }:
{
  myOptions = {
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      systemarch = "x86_64-linux"; # system arch
      hostname = "Ainz-NIX"; # hostname
      timezone = "Asia/Kolkata"; # select timezone
      locale = "en_US.UTF-8"; # select locale
      additionalLocale = "en_IN";
      stableversion = "24.11";
      secureboot = true;
      laptop = false;
    };

    # ----- USER SETTINGS ----- #
    userSettings = {
      username = "masum"; # username
      name = "Masum R."; # name/identifier
      gitname = "John Titor"; # git name
      gitemail = "50095635+JohnRTitor@users.noreply.github.com"; # git email
      gpgkey = "29B0514F4E3C1CC0"; # gpg key
      shell = "zsh"; # user default shell # choose either zsh or bash
    };

    servicesSettings = {
      adb = false;
      avahi = false;
      nginx = false;
      containers = false;
      tpm = false;
      virtualisation = false;
      printing = false;
      apparmor = false;
    };
  };
}
