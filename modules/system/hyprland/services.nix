{ lib, pkgs, ... }:
{
  ## Configure XDG portal ##
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal
  };
}
