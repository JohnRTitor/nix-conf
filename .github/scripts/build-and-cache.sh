#!/usr/bin/env bash
set -euo pipefail

# Configuration with defaults
CACHIX_CACHE_NAME="${CACHIX_CACHE_NAME:-}"
NIXOS_HOSTNAME="${NIXOS_HOSTNAME:-}"
NIXOS_USER="${NIXOS_USER:-}"
NIXOS_ATTRS_LIST="${NIXOS_ATTRS_LIST:-}"
NIXOS_PKGS_LIST="${NIXOS_PKGS_LIST:-}"
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

  if [ -z "$NIXOS_HOSTNAME" ]; then
    echo_error "NIXOS_HOSTNAME is required"
    exit 1
  fi

  if [ -z "$NIXOS_USER" ]; then
    echo_error "NIXOS_USER is required"
    exit 1
  fi

  # Check if cachix is available
  if ! command -v cachix >/dev/null 2>&1; then
    echo_error "cachix command not found"
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

# Get list of packages to build
function get_packages_list() {
  local pkgs_list
  if ! pkgs_list=$(nix flake show --json 2>/dev/null | jq -r '.packages."x86_64-linux" | keys | join(" ")' 2>/dev/null); then
    echo_error "Failed to get package list from flake" >&2
    exit 1
  fi

  # Add NixOS configuration attributes
  if [ -n "$NIXOS_ATTRS_LIST" ]; then
    for attr in $NIXOS_ATTRS_LIST; do
      pkgs_list+=" nixosConfigurations.$NIXOS_HOSTNAME.config.$attr"
    done
  fi

  # Add NixOS packages
  if [ -n "$NIXOS_PKGS_LIST" ]; then
    for pkg in $NIXOS_PKGS_LIST; do
      pkgs_list+=" nixosConfigurations.$NIXOS_HOSTNAME.pkgs.$pkg"
    done
  fi

  echo "$pkgs_list"
}

# Get VSCode extensions
function get_vscode_extensions() {
  local vscode_path=".#nixosConfigurations.$NIXOS_HOSTNAME.config.home-manager.users.$NIXOS_USER.programs.vscode.profiles.default.extensions"

  # Get extension names
  local ext_names
  if ! ext_names=$(nix eval --json "$vscode_path" --apply 'map (drv: drv.pname)' 2>/dev/null | jq -r '.[]' 2>/dev/null); then
    echo_warning "Failed to get VSCode extensions names" >&2
    ext_names=""
  fi

  # Get extension derivations
  local ext_drvs
  if ! ext_drvs=$(nix eval --json "$vscode_path" --apply 'map (drv: drv.drvPath)' 2>/dev/null | jq -r '.[]' 2>/dev/null); then
    echo_warning "Failed to get VSCode extensions derivations" >&2
    ext_drvs=""
  fi

  echo "$ext_names|$ext_drvs"
}

# Update GitHub step summary
function update_step_summary() {
  local pkgs_list="$1"
  local vscode_names="$2"

  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    {
      echo "## 📦 Flake Attributes to Build"
      echo '```'
      printf '%s\n' $pkgs_list
      echo '```'
      echo
      echo "## 🔧 VSCode Extensions to Build"
      echo '```'
      echo "$vscode_names"
      echo '```'
      echo
    } >> "$GITHUB_STEP_SUMMARY"
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

  echo_info "Fetching list of packages to build"
  # Get packages and extensions
  local pkgs_list
  pkgs_list=$(get_packages_list)

  echo_info "Fetching VSCode extensions list"
  local vscode_info
  vscode_info=$(get_vscode_extensions)
  local vscode_names="${vscode_info%|*}"
  local vscode_drvs="${vscode_info#*|}"

  # Update GitHub summary
  update_step_summary "$pkgs_list" "$vscode_names"

  echo_info "Starting package builds"

  # Build packages
  local build_failures=0
  for pkg in $pkgs_list; do
    if ! build_package "$pkg" "flake package"; then
      ((build_failures++))
    fi
    # Small delay between builds
    sleep 1
  done

  echo_info "Starting VSCode extension builds"

  # Build VSCode extensions
  if [ -n "$vscode_drvs" ]; then
    # Convert derivations and names to arrays for parallel processing
    local -a drv_array name_array
    read -ra drv_array <<< "$vscode_drvs"
    read -ra name_array <<< "$vscode_names"

    for i in "${!drv_array[@]}"; do
      local drv="${drv_array[i]}"
      local name="${name_array[i]:-unknown-$i}"

      if ! build_drv "$drv" "$name" "VSCode extension"; then
        ((build_failures++))
      fi
      # Small delay between builds
      sleep 1
    done
  else
    echo_warning "No VSCode extensions found to build"
  fi

  # Exit with error if any builds failed
  if [ $build_failures -gt 0 ]; then
    echo_error "$build_failures build(s) failed"
    exit 1
  fi

  echo_success "All builds completed successfully"
}

# Run main function
main "$@"
