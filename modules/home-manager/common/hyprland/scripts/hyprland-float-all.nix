{ pkgs }:
pkgs.writeShellScriptBin "hyprland-float-all" ''
  #!/usr/bin/env bash
  set -euo pipefail

  ws="$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .id)"
  ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg ws "$ws" '.[] | select(.workspace.id == ($ws|tonumber)) | .address' \
    | while read -r addr; do
        [ -n "''${addr:-}" ] && ${pkgs.hyprland}/bin/hyprctl dispatch togglefloating "address:$addr"
      done
''
