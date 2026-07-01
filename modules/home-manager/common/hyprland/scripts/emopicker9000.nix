{ pkgs }:

pkgs.writeShellApplication {
  name = "emopicker9000";

  runtimeInputs = with pkgs; [
    rofi
    ydotool
    wl-clipboard
    libnotify
    coreutils
    gawk
    procps
  ];

  text = ''
    set -euo pipefail

    EMOJI_FILE="$HOME/.config/.emoji"
    ROFI_CONFIG="$HOME/.config/rofi/config-long.rasi"

    usage() {
      cat <<EOF
    Usage: emopicker9000 [--type]

    Options:
    --type     Type the selected emoji using ydotool.
                Default behavior copies it to the clipboard.
    -h, --help Show this help message.
    EOF
        }

    MODE="clipboard"

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type)
          MODE="type"
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

    if pidof rofi >/dev/null 2>&1; then
      pkill rofi
    fi

    [[ -f "$EMOJI_FILE" ]] || {
      notify-send "Emoji Picker" "Emoji database not found: $EMOJI_FILE"
      exit 1
    }

    chosen="$(
      rofi \
        -i \
        -dmenu \
        -config "$ROFI_CONFIG" \
        < "$EMOJI_FILE" \
      | awk '{print $1}'
    )"

    [[ -n "$chosen" ]] || exit 0

    case "$MODE" in
      type)
        ydotool type "$chosen"
        ;;

      clipboard)
        printf "%s" "$chosen" | wl-copy
        notify-send "Emoji Picker" "$chosen copied to clipboard."
        ;;
    esac
  '';
}
