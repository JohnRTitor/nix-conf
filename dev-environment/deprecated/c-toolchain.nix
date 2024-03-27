## DEPRECATED - use devenv instead ##
# This config files is used for configuring a C++ development environment
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    llvmPackages.libcxxClang
    clang
    gnumake # make
  ];
}