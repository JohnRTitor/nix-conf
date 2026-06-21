#!/usr/bin/env bash
set -euo pipefail

# Configuration with defaults
CACHIX_CACHE_NAME="${CACHIX_CACHE_NAME:-}"
BUILD_FLAGS="${BUILD_FLAGS:---print-out-paths --print-build-logs}"

# Colors for output
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[0m'

# Echo helpers
function echo_warning() {
  echo -ne "${Y}WARNING:${W} "
  echo "$@"
}

function echo_error() {
  echo -ne "${R}ERROR:${W} " 1>&2
  echo "$@" 1>&2
}

function echo_success() {
  echo -ne "${G}SUCCESS:${W} "
  echo "$@"
}

function echo_info() {
  echo -ne "${C}INFO:${W} "
  echo "$@"
}

# Preparation function
function prepare() {
  # Initialize log files
  touch build.log errors.log success.txt failures.txt

  echo_info "Starting build preparation"

  # Validate required variables
  if [ -z "$CACHIX_CACHE_NAME" ]; then
    echo_error "CACHIX_CACHE_NAME is required"
    exit 1
  fi

  # Check if cachix is available
  if ! command -v cachix >/dev/null 2>&1; then
    echo_error "cachix command not found"
    exit 1
  fi

  # Check if jq is available
  if ! command -v jq >/dev/null 2>&1; then
    echo_error "jq command not found"
    exit 1
  fi

  # Warn if we don't have cachix authentication
  if [ -z "${CACHIX_AUTH_TOKEN:-}" ] && [ -z "${CACHIX_SIGNING_KEY:-}" ]; then
    echo_warning "No cachix authentication token or signing key found"
  fi
}

# Build a single package
function build_package() {
  local pkg="$1"
  local description="$2"

  echo -n "* Building $description ($pkg)..."

  # Check if build should be aborted
  if [ -e "abort" ]; then
    echo -e "${R} ABORTED${W}"
    return 1
  fi

  # Start keepalive for long builds
  (while true; do
    echo -ne "${C} BUILDING${W}\n* Building $description ($pkg)..."
    sleep 120
  done) &
  local keepalive=$!

  # Ensure keepalive is killed on function exit
  trap "kill $keepalive 2>/dev/null || true" RETURN

  {
    echo "--- Building: $pkg ---"
    echo "Command: nix build .#$pkg $BUILD_FLAGS"
  } >> build.log

  # Attempt to build
  if nix build ".#$pkg" $BUILD_FLAGS 2>> errors.log | tee -a build.log | cachix push "$CACHIX_CACHE_NAME"; then
    # Build succeeded
    kill $keepalive 2>/dev/null || true
    echo -e "${G} SUCCESS${W}"
    echo "$pkg" >> success.txt
    return 0
  else
    # Build failed
    kill $keepalive 2>/dev/null || true
    echo -e "${R} FAILED${W}"
    echo "$pkg" >> failures.txt
    {
      echo "--- FAILED: $pkg ---"
      echo "Last 20 lines of error log:"
      tail -20 errors.log
    } >> build.log
    return 1
  fi
}

# Build derivation
function build_drv() {
  local drv="$1"
  local name="$2"
  local description="${3:-derivation}"

  echo -n "* Building $description: $name..."

  # Check if build should be aborted
  if [ -e "abort" ]; then
    echo -e "${R} ABORTED${W}"
    return 1
  fi

  # Start keepalive for long builds
  (while true; do
    echo -ne "${C} BUILDING${W}\n* Building $description: $name..."
    sleep 120
  done) &
  local keepalive=$!

  # Ensure keepalive is killed on function exit
  trap "kill $keepalive 2>/dev/null || true" RETURN

  {
    echo "--- Building $description: $name ---"
    echo "Command: nix build ${drv}^* --print-build-logs --print-out-paths"
  } >> build.log

  # Attempt to build
  if nix build "${drv}^*" --print-build-logs --print-out-paths 2>> errors.log | tee -a build.log | cachix push "$CACHIX_CACHE_NAME"; then
    # Build succeeded
    kill $keepalive 2>/dev/null || true
    echo -e "${G} SUCCESS${W}"
    echo "drv:$name" >> success.txt
    return 0
  else
    # Build failed
    kill $keepalive 2>/dev/null || true
    echo -e "${R} FAILED${W}"
    echo "drv:$name" >> failures.txt
    {
      echo "--- FAILED $description: $name ---"
      echo "Last 20 lines of error log:"
      tail -20 errors.log
    } >> build.log
    return 1
  fi
}

function build_target() {
  local target_json="$1"
  local group=$(echo "$target_json" | jq -r '.group')
  local name=$(echo "$target_json" | jq -r '.name // empty')
  local hostname=$(echo "$target_json" | jq -r '.hostname // empty')
  local user=$(echo "$target_json" | jq -r '.user // empty')

  if [ "$group" = "flake_package" ]; then
    if [ -z "$name" ] || [ "$name" = "all" ]; then
      local pkgs=$(nix flake show --json 2>/dev/null | jq -r '.packages."x86_64-linux" | keys | join(" ")' 2>/dev/null)
      local failed=0
      for p in $pkgs; do
        build_package "$p" "flake package" || failed=1
        sleep 1
      done
      return $failed
    else
      build_package "$name" "flake package" || return 1
    fi
  elif [ "$group" = "nixos_config_attribute" ]; then
    build_package "nixosConfigurations.$hostname.config.$name" "NixOS config attribute ($hostname)" || return 1
  elif [ "$group" = "nixos_package" ]; then
    build_package "nixosConfigurations.$hostname.pkgs.$name" "NixOS package ($hostname)" || return 1
  elif [ "$group" = "vscode_extensions" ]; then
    local vscode_path=".#nixosConfigurations.$hostname.config.home-manager.users.$user.programs.vscode.profiles.default.extensions"
    local ext_names ext_drvs
    
    if ! ext_names=$(nix eval --json "$vscode_path" --apply 'map (drv: drv.pname)' 2>/dev/null | jq -r '.[]' 2>/dev/null); then
      echo_warning "Failed to get VSCode extension names for $user@$hostname"
      return 0
    fi
    
    if ! ext_drvs=$(nix eval --json "$vscode_path" --apply 'map (drv: drv.drvPath)' 2>/dev/null | jq -r '.[]' 2>/dev/null); then
      echo_warning "Failed to get VSCode extension derivations for $user@$hostname"
      return 0
    fi

    if [ -z "$ext_drvs" ]; then
      echo_warning "No VSCode extensions found for $user@$hostname"
      return 0
    fi

    mapfile -t drv_array <<< "$ext_drvs"
    mapfile -t name_array <<< "$ext_names"

    local failed=0
    for i in "${!drv_array[@]}"; do
      local drv="${drv_array[i]}"
      local ext_name="${name_array[i]:-unknown-$i}"
      [ -z "$drv" ] && continue
      if ! build_drv "$drv" "$ext_name" "VSCode extension ($hostname/$user)"; then
        failed=1
      fi
      sleep 1
    done
    return $failed
  else
    echo_error "Unknown group: $group"
    return 1
  fi
}

# Generate final report
function generate_report() {
  local success_count=$(wc -l < success.txt 2>/dev/null || echo 0)
  local failure_count=$(wc -l < failures.txt 2>/dev/null || echo 0)
  local total_count=$((success_count + failure_count))

  echo
  echo "================================="
  echo "Build Summary"
  echo "================================="
  echo "Total builds: $total_count"
  echo "Successful: $success_count"
  echo "Failed: $failure_count"
  echo "================================="

  if [ $failure_count -gt 0 ]; then
    echo
    echo "Failed builds:"
    cat failures.txt 2>/dev/null | sed 's/^/  - /'
  fi

  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    {
      echo
      echo "## 📊 Build Summary"
      echo "- **Total builds:** $total_count"
      echo "- **Successful:** $success_count"
      echo "- **Failed:** $failure_count"

      if [ $failure_count -gt 0 ]; then
        echo
        echo "### ❌ Failed Builds"
        cat failures.txt 2>/dev/null | sed 's/^/- /' || echo "- None"
      fi
    } >> "$GITHUB_STEP_SUMMARY"
  fi
}

# Cleanup function
function cleanup() {
  local exit_code=$?

  # Kill any remaining background processes
  jobs -p | xargs -r kill 2>/dev/null || true

  # Generate final report
  generate_report

  echo_info "Cleanup completed"

  exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Main execution
function main() {
  prepare

  local build_failures=0

  if [ $# -gt 0 ]; then
    # If an argument is provided, treat it as a specific target JSON (e.g. from matrix)
    local target_json="$1"
    echo_info "Building specific target: $target_json"
    if ! build_target "$target_json"; then
      ((build_failures++))
    fi
  else
    # Default behavior: read cache.json and build all targets sequentially
    if [ ! -f "cache.json" ]; then
      echo_error "cache.json not found in repository root"
      exit 1
    fi

    echo_info "Reading targets from cache.json"
    local targets_count=$(jq '.targets | length' cache.json)
    
    for (( i=0; i<$targets_count; i++ )); do
      local target_json=$(jq -c ".targets[$i]" cache.json)
      echo_info "Processing target $[i+1]/$targets_count..."
      if ! build_target "$target_json"; then
        ((build_failures++))
      fi
      sleep 1
    done
  fi

  # Exit with error if any builds failed
  if [ $build_failures -gt 0 ]; then
    echo_error "$build_failures target(s) failed"
    exit 1
  fi

  echo_success "All targets completed successfully"
}

# Run main function
main "$@"
