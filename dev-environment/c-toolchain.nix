{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libgcc # gcc
    llvmPackages.libcxxClang
    clang
    gnumake # make
  ];
}