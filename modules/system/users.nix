# This conf file is used to configure user accounts in the system
{
  config,
  self,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${config.myOptions.userSettings."masum".username} = {
    isNormalUser = true;
    description = config.myOptions.userSettings."masum".name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    # user shell changed to zsh
    shell = if (config.myOptions.userSettings."masum".shell == "zsh") then pkgs.zsh else pkgs.bashInteractive;
  };

  users.users."masum-work" = {
    isNormalUser = true;
    description = config.myOptions.userSettings."masum-work".name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Configure in ../pkgs/user-packages.nix
    ];
    shell = if (config.myOptions.userSettings."masum-work".shell == "zsh") then pkgs.zsh else pkgs.bashInteractive;
  };
}
