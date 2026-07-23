{ ... }:
{
  myOptions = {
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      systemarch = "x86_64-linux"; # system arch
      timezone = "Asia/Kolkata"; # select timezone
      locale = "en_US.UTF-8"; # select locale
      additionalLocale = "en_IN";
      stableversion = "24.11";
      bootloader = "limine";
      laptop = false;
      tpm = false;
      stylixImage = ../wallpapers/Fantasy-Japanese-Street.png;
    };

    # ----- USER SETTINGS ----- #
    userSettings."masum" = {
      username = "masum";
      name = "Masum R.";
      gitname = "John Titor";
      gitemail = "50095635+JohnRTitor@users.noreply.github.com";
      gpgkey = "29B0514F4E3C1CC0";
      shell = "zsh"; # user default shell # choose either zsh or bash
      clockType = "24h";
      default-browser = "google-chrome";
    };
    userSettings."masum-work" = {
      username = "masum-work";
      name = "Masum R. Work";
      gitname = "Masum Reza";
      gitemail = "221108133+johnrtitor-work@users.noreply.github.com";
      gpgkey = "157769ECD30424AF";
      shell = "zsh"; # user default shell # choose either zsh or bash
      clockType = "24h";
      default-browser = "google-chrome";
    };

    servicesSettings = {
      avahi = false;
      containers = false;
      tpm = false;
      virtualisation = false;
      printing = false;
      apparmor = false;
    };

    devSettings = {
      nginx = false;
      jupyter = false;
      mysql = false;
      postgresql = true;
    };

    programsSettings = {
      displayManager = "gdm";
      fileManager = "dolphin";
      terminal = "kitty";
      guiSuite = "kde";
      openrgb = true;
    };
  };
}
