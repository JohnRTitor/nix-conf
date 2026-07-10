{ self, pkgs, ... }: {
  qt.enable = true;

  qt.style.name = "kvantum";
  qt.kvantum.enable = true;
  qt.kvantum.settings.General.theme = "Utterly-Sweet";
  qt.kvantum.themes = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.utterly-sweet-kvantum
  ];
}
