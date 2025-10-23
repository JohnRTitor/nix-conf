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
  users.users.${userSettings."masum".username} = {
    isNormalUser = true;
    description = userSettings."masum".name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    # user shell changed to zsh
    shell = if (userSettings."masum".shell == "zsh") then pkgs.zsh else pkgs.bashInteractive;
  };

  users.users."masum-work" = {
    isNormalUser = true;
    description = userSettings."masum-work".name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    shell = if (userSettings."masum-work".shell == "zsh") then pkgs.zsh else pkgs.bashInteractive;
  };
}
