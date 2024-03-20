{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gccStdenv # gcc and c tools
    gnumake # make
  ];
}