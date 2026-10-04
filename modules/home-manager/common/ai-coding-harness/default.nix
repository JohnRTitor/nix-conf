{
  self,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode
    ./cline
  ];
  home.packages = [
    # self.packages.${pkgs.stdenv.hostPlatform.system}.freebuff
  ];
}
