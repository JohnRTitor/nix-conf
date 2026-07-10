{ self, pkgs, ... }: {
  qt.enable = true;

  qt.style.name = "kvantum";
  qt.kvantum.enable = true;
  qt.kvantum.settings.General.theme = "BonaFides-Rounded-Kvantum";
  qt.kvantum.themes = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.bonafides-rounded-kvantum
  ];
}
