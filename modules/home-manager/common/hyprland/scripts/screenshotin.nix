{ pkgs }:

pkgs.writeShellApplication {
  name = "screenshootin";

  runtimeInputs = with pkgs; [
    grim # screenshot tool, it can utilise slurp
    slurp # region selector in linux
    swappy # screenshot view/edit
    libnotify # Provides notify-send
    jq # Required for Hyprland JSON parsing
    coreutils # Provides mktemp, mkdir, sleep, rm, etc.
  ];

  text = ''
      set -euo pipefail

      SILENT=false
      # Global variable to track our temporary screenshot file
      TEMP_FILE=""

      # Wrapper function for notifications
      send_notification() {
          if [[ "$SILENT" == "false" ]]; then
              notify-send "$@"
          fi
      }

      # Cleanup trap to ensure temporary files are deleted on exit
      cleanup() {
          local exit_code=$?
          if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
              rm -f "$TEMP_FILE"
          fi
          exit "$exit_code"
      }
      trap cleanup EXIT

      # Cancellation trap for Ctrl+C
      handle_cancel() {
          send_notification "Screenshot Cancelled" "Operation cancelled by user."
          exit 130
      }
      trap handle_cancel INT TERM

      # Utility function to check for dependencies. 
      # Note: Due to Nix makeBinPath above, these should always exist, 
      # but it's good practice to keep the checks in the bash script.
      check_dep() {
          if ! command -v "$1" >/dev/null 2>&1; then
              send_notification "Screenshot Error" "Missing dependency: $1" -u critical
              echo "Error: Missing dependency: $1" >&2
              exit 1
          fi
      }

      check_dep grim
      check_dep swappy
      check_dep notify-send

      # Usage text
      usage() {
          cat <<EOF
    Usage: screenshootin [OPTIONS]

    A screenshot utility for Wayland.

    Options:
      --fullscreen    Capture the entire screen
      --output        Capture the currently active output
      --window        Capture the currently focused window (Hyprland supported)
      --timer N       Wait N seconds before capturing the entire screen
      --silent, --dont-notify Disable all desktop notifications
      --help, -h      Show this help message

    Default behavior is interactive region selection.
    EOF
      }

      MODE="region"
      TIMER=0

      # Argument parsing
      while [[ $# -gt 0 ]]; do
          case "$1" in
              --fullscreen)
                  MODE="fullscreen"
                  shift
                  ;;
              --output)
                  MODE="output"
                  shift
                  ;;
              --window)
                  MODE="window"
                  shift
                  ;;
              --timer)
                  if [[ -n "''${2:-}" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                      TIMER="$2"
                      MODE="fullscreen" # Timer mode always captures the entire screen
                      shift 2
                  else
                      echo "Error: --timer requires a numeric argument." >&2
                      exit 1
                  fi
                  ;;
              --silent|--dont-notify)
                  SILENT=true
                  shift
                  ;;
              --help|-h)
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

      # Timer logic
      if [[ "$TIMER" -gt 0 ]]; then
          for (( i=TIMER; i>0; i-- )); do
              if (( i > 1 )); then # inhibit last second notification, to capture the fullscreen cleanly
                # Use a synchronous notification to prevent spamming multiple popups
                send_notification "Screenshot" "Screenshot in $i seconds..." \
                    -t 1000 \
                    -h string:x-canonical-private-synchronous:screenshootin-timer
              fi
              sleep 1
          done
      fi

      # Core capture and edit function
      capture_with_args() {
          TEMP_FILE="$(mktemp --suffix=.png)"

          # Run grim. If it fails (e.g. invalid region), catch the error.
          if ! grim "$@" "$TEMP_FILE"; then
              send_notification "Screenshot Cancelled" "Screenshot operation was cancelled."
              exit 0
          fi

          send_notification "Screenshot Captured" "Opening screenshot in Swappy."
          swappy -f "$TEMP_FILE"
      }

      # Mode execution logic
      case "$MODE" in
          region)
              check_dep slurp
              # Disable 'exit on error' temporarily so we can gracefully handle slurp cancellation
              set +e
              geometry=$(slurp)
              slurp_exit=$?
              set -e
              
              if [[ $slurp_exit -ne 0 ]] || [[ -z "$geometry" ]]; then
                  send_notification "Screenshot Cancelled" "Region selection cancelled."
                  exit 0
              fi
              capture_with_args -g "$geometry"
              ;;

          fullscreen)
              capture_with_args
              ;;

          output)
              # Check if we can determine the active output via Hyprland
              if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
                  active_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
                  if [[ -n "$active_monitor" && "$active_monitor" != "null" ]]; then
                      capture_with_args -o "$active_monitor"
                      exit 0
                  fi
              fi
              
              # Fallback to fullscreen if output detection fails
              send_notification "Screenshot" "Active output detection failed. Falling back to fullscreen."
              capture_with_args
              ;;

          window)
              # Check if we can determine the active window geometry via Hyprland
              if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
                  window_info=$(hyprctl activewindow -j)
                  if [[ "$(echo "$window_info" | jq -r '.class')" != "null" ]]; then
                      # Hyprland returns window coordinates and size
                      geometry=$(echo "$window_info" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
                      if [[ -n "$geometry" && "$geometry" != "null,null nullxnull" ]]; then
                          capture_with_args -g "$geometry"
                          exit 0
                      fi
                  fi
              fi
              
              # Fallback to interactive region selection
              send_notification "Screenshot" "Active window detection unsupported or failed. Falling back to region selection."
              check_dep slurp
              set +e
              geometry=$(slurp)
              slurp_exit=$?
              set -e
              
              if [[ $slurp_exit -ne 0 ]] || [[ -z "$geometry" ]]; then
                  send_notification "Screenshot Cancelled" "Region selection cancelled."
                  exit 0
              fi
              capture_with_args -g "$geometry"
              ;;
      esac
  '';
}
