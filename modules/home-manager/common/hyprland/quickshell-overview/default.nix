{
  config,
  lib,
  ...
}:
let
  overviewSource = ./src;
in
{
  # Quickshell-overview is a Qt6 QML app for Hyprland workspace overview
  # It shows all workspaces with live window previews, drag-and-drop support
  # Toggled via: SUPER + TAB (bound in hyprland/binds.nix)
  # Started via exec-once in hyprland/exec-once.nix

  # Seed the Quickshell overview code into ~/.config/quickshell/overview
  # Copy (not symlink) so QML module resolution works and users can edit files
  home.activation.seedOverviewCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    DEST="$HOME/.config/quickshell/overview"
    SRC="${overviewSource}"

    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/quickshell"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"
    fi
  '';
}
