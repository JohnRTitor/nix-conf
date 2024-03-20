{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libgcc # gcc
    gnumake # make
  ];
}