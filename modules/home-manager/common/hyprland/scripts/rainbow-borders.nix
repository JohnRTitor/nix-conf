{ pkgs }:

pkgs.writeShellApplication {
  name = "random-border-colors";

  runtimeInputs = with pkgs; [
    openssl
  ];

  text = ''
    set -euo pipefail

    usage() {
     cat <<EOF
    Usage: random-border-colors [OPTIONS]

    Randomize Hyprland window border colors.

    Options:
      --all       Randomize both active and inactive borders.
      -h, --help  Show this help message.
    EOF
    }

    RANDOMIZE_ALL=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --all)
            RANDOMIZE_ALL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        esac
    done

    build_gradient() {
        printf '{ colors = { '

        for ((i = 0; i < 10; i++)); do
        printf '"0xff%s"' "$(openssl rand -hex 3)"

        if (( i < 9 )); then
            printf ', '
        fi
        done

        printf ' }, angle = 270 }'
    }

    ACTIVE_BORDER="$(build_gradient)"

    CONFIG="
    hl.config({
        general = {
        col = {
            active_border = $ACTIVE_BORDER,"

    if [[ "$RANDOMIZE_ALL" == true ]]; then
        INACTIVE_BORDER="$(build_gradient)"

        CONFIG+="
            inactive_border = $INACTIVE_BORDER,"
    fi

    CONFIG+="
        }
        }
    })
    "

    hyprctl eval "$CONFIG"
  '';
}
