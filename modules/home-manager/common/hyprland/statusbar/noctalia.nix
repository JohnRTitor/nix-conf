{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaPkg = pkgs.noctalia-shell;
  configDir = "${noctaliaPkg}/share/noctalia-shell";
in
{
  # Install the Noctalia package
  home.packages = with pkgs; [
    noctaliaPkg
    quickshell # Ensure quickshell is available for the service

    matugen # color palette generator needed for noctalia-shell
    app2unit # launcher for noctalia-shell
    gpu-screen-recorder # needed for nnoctalia-shell
  ];

  # Seed the configuration
  home.activation.seedNoctaliaShellCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/quickshell"
      $DRY_RUN_CMD cp -R "$SRC" "$DEST"
      $DRY_RUN_CMD chmod -R u+rwX "$DEST"
    fi
  '';
}
