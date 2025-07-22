# This conf file is used to configure user accounts in the system
{
  self,
  pkgs,
  pkgs-master,
  systemSettings,
  userSettings,
  inputs,
  ...
}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    # user shell changed to zsh
    shell = if (userSettings.shell == "zsh") then pkgs.zsh else pkgs.bashInteractive;
  };

  users.users."masum-work" = {
    isNormalUser = true;
    description = "Masum R. Work";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    # user shell changed to zsh
    shell = pkgs.zsh;
  };
}
