#!/usr/bin/env bash
set -euo pipefail

TARGETS_JSON=$1
CACHIX_CACHE_NAME=$2

echo "Input targets: $TARGETS_JSON"
echo "Cache name: $CACHIX_CACHE_NAME"

MISSING_TARGETS="[]"

for row in $(echo "${TARGETS_JSON}" | jq -r '.[] | @base64'); do
    _jq() {
     echo "${row}" | base64 --decode | jq -r "${1}"
    }
    
    TARGET_JSON=$(echo "${row}" | base64 --decode)
    GROUP=$(_jq '.group')
    HOSTNAME=$(_jq '.hostname // empty')
    NAME=$(_jq '.name // empty')
    USER=$(_jq '.user // empty')

    OUT_PATH=""
    if [ "$GROUP" = "nixos_config_attribute" ]; then
        OUT_PATH=$(nix eval --raw ".#nixosConfigurations.$HOSTNAME.config.$NAME.outPath" 2>/dev/null || true)
    elif [ "$GROUP" = "nixos_package" ]; then
        OUT_PATH=$(nix eval --raw ".#nixosConfigurations.$HOSTNAME.pkgs.$NAME.outPath" 2>/dev/null || true)
    elif [ "$GROUP" = "vscode_extensions" ]; then
       OUT_PATH="always_build"
    fi

    BUILD_IT=false
    if [ -z "$OUT_PATH" ]; then
        BUILD_IT=true
        echo "Could not evaluate $NAME, adding to build matrix."
    elif [ "$OUT_PATH" = "always_build" ]; then
        BUILD_IT=true
        echo "Always building group $GROUP"
    else
        HASH=$(basename "$OUT_PATH" | cut -d'-' -f1)
        if ! curl -sSf "https://${CACHIX_CACHE_NAME}.cachix.org/${HASH}.narinfo" > /dev/null 2>&1; then
            BUILD_IT=true
            echo "Target $NAME ($HASH) is missing from Cachix."
        else
            echo "Target $NAME ($HASH) is already in Cachix, skipping."
        fi
    fi

    if [ "$BUILD_IT" = true ]; then
        MISSING_TARGETS=$(echo "$MISSING_TARGETS" | jq ". + [$TARGET_JSON]")
    fi
done

COMPACT_TARGETS=$(echo "$MISSING_TARGETS" | jq -c .)
echo "Filtered targets: $COMPACT_TARGETS"

echo "targets=$COMPACT_TARGETS" >> $GITHUB_OUTPUT

if [ "$COMPACT_TARGETS" = "[]" ]; then
  echo "has_targets=false" >> $GITHUB_OUTPUT
else
  echo "has_targets=true" >> $GITHUB_OUTPUT
fi
