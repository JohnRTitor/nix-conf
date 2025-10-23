{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [
    # "aarch64-linux" # enables running aarch64 binaries and compilation using qemu
    # "x86_64-windows" # running exe files using wine
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      # Extra libraries and packages for Appimage run
      extraPkgs =
        pkgs: with pkgs; [
          ffmpeg
          imagemagick
        ];
    };
  };

  # enable flatpak support
  # flatpak configured via nix-flatpak flake modules
  # which allows installing flatpak packages declaratively
  # install flatpak packages in ./global-packages.nix or ./user-packages.nix
  services.flatpak.enable = true;
}
