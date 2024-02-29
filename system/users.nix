# This conf file is used to configure user accounts in the system
{ userSettings, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "input" "audio" ];
    packages = with pkgs; [
        # Configure in ../home.nix
    ];
  };
}