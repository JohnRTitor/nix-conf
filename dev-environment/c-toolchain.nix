{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    llvmPackages.libcxxClang
    clang
    gnumake # make
  ];
}