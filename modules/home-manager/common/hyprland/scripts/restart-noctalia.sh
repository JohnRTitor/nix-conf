#!/usr/bin/env bash
set -euo pipefail

# Restart the Noctalia QuickShell session by terminating only the noctalia-shell
# processes, avoiding any signals to unrelated process groups (e.g. Hyprland).

log() { printf "[restart.noctalia] %s\n" "$*"; }

list_target_pids() {
  # Collect only PIDs whose command explicitly runs noctalia-shell
  # - direct wrapper: ".../noctalia-shell"
  # - quickshell/qs with "-c noctalia-shell"
  ps -eo pid=,cmd= \
    | ${GREP:-grep} -E "(^|/)(noctalia-shell)( |$)|(^| )((qs|quickshell))( | ).*-c( |=)?noctalia-shell( |$)" \
    | awk '{print $1}'
}

terminate_targets() {
  local pids left tries
  mapfile -t pids < <(list_target_pids || true)

  if ((${#pids[@]} > 0)); then
    kill -TERM "${pids[@]}" 2>/dev/null || true
  fi

  # Wait up to ~3s for clean exit
  for tries in {1..15}; do
    mapfile -t left < <(list_target_pids || true)
    ((${#left[@]} == 0)) && break
    sleep 0.2
  done

  # Force kill leftovers only (do not touch anything else)
  if ((${#left[@]} > 0)); then
    kill -KILL "${left[@]}" 2>/dev/null || true
  fi
}

start_noctalia() {
  # Prefer the noctalia-shell wrapper to ensure proper env and runtime flags
  if command -v noctalia-shell >/dev/null 2>&1; then
    nohup setsid noctalia-shell >/dev/null 2>&1 &
  elif command -v quickshell >/dev/null 2>&1; then
    nohup setsid quickshell -c noctalia-shell >/dev/null 2>&1 &
  elif command -v qs >/dev/null 2>&1; then
    nohup setsid qs -c noctalia-shell >/dev/null 2>&1 &
  else
    echo "Error: noctalia-shell/quickshell/qs not found in PATH" >&2
    exit 1
  fi
}

terminate_targets
start_noctalia
