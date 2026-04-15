{ pkgs, ... }:
let
  binPath = pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.procps
    pkgs.psmisc
    pkgs.gnugrep
    pkgs.findutils
    pkgs.util-linux
    pkgs.bash
  ];
  script = builtins.readFile ./restart-noctalia.nix;
in
pkgs.writeShellScriptBin "restart.noctalia" ''
    set -euo pipefail
    export PATH=${binPath}:$PATH

    tmp_script=$(mktemp)
    trap 'rm -f "$tmp_script"' EXIT
    cat > "$tmp_script" <<'BASH_EOF'
  ${script}
  BASH_EOF
    chmod +x "$tmp_script"
    exec ${pkgs.bash}/bin/bash "$tmp_script" "$@"
''
