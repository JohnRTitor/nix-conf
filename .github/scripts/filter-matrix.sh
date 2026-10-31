#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq command not found" >&2
    exit 1
fi

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

    TARGET_REF=""
    ALWAYS_BUILD=false
    if [ "$GROUP" = "nixos_config_attribute" ]; then
        TARGET_REF=".#nixosConfigurations.$HOSTNAME.config.$NAME"
    elif [ "$GROUP" = "nixos_package" ]; then
        TARGET_REF=".#nixosConfigurations.$HOSTNAME.pkgs.$NAME"
    elif [ "$GROUP" = "vscode_extensions" ]; then
        ALWAYS_BUILD=true
    elif [ "$GROUP" = "flake_package" ]; then
        if [ -z "$NAME" ] || [ "$NAME" = "all" ]; then
            ALWAYS_BUILD=true
        else
            TARGET_REF=".#$NAME"
        fi
    elif [ "$GROUP" = "remote_flake" ]; then
        TARGET_REF="$NAME"
    fi

    BUILD_IT=false
    if [ "$ALWAYS_BUILD" = true ]; then
        BUILD_IT=true
        echo "Always building group $GROUP"
    elif [ -z "$TARGET_REF" ]; then
        BUILD_IT=true
        echo "Unknown target group $GROUP, adding to build matrix."
    else
        NIX_APPLY_EXPR='pkg:
          let
            installedOutputs =
              if pkg ? meta.outputsToInstall && builtins.isList pkg.meta.outputsToInstall
              then map (out: if pkg ? ${out} then (pkg.${out}.outPath or pkg.${out}) else (pkg.outPath or pkg)) pkg.meta.outputsToInstall
              else [ (pkg.outPath or pkg) ];
          in
            map toString installedOutputs'

        OUT_PATHS=$(nix eval --no-eval-cache --json "$TARGET_REF" --apply "$NIX_APPLY_EXPR" 2>/dev/null | jq -r '.[]' 2>/dev/null | sort -u || true)

        if [ -z "$OUT_PATHS" ]; then
            BUILD_IT=true
            echo "Could not evaluate $NAME, adding to build matrix."
        else
            while IFS= read -r OUT_PATH; do
                [ -z "$OUT_PATH" ] && continue
                HASH=$(basename "$OUT_PATH" | cut -d'-' -f1)
                CACHED=false
                if curl -sSf "https://${CACHIX_CACHE_NAME}.cachix.org/${HASH}.narinfo" > /dev/null 2>&1; then
                    echo "Output path $OUT_PATH ($HASH) for target $NAME is already in your Cachix."
                    CACHED=true
                elif curl -sSf "https://cache.nixos.org/${HASH}.narinfo" > /dev/null 2>&1; then
                    echo "Output path $OUT_PATH ($HASH) for target $NAME is already in upstream NixOS cache."
                    CACHED=true
                elif curl -sSf "https://nix-community.cachix.org/${HASH}.narinfo" > /dev/null 2>&1; then
                    echo "Output path $OUT_PATH ($HASH) for target $NAME is already in nix-community cache."
                    CACHED=true
                elif curl -sSf "https://nyx-cache.chaotic.cx/${HASH}.narinfo" > /dev/null 2>&1; then
                    echo "Output path $OUT_PATH ($HASH) for target $NAME is already in chaotic cache."
                    CACHED=true
                fi

                if [ "$CACHED" = false ]; then
                    BUILD_IT=true
                    echo "Target $NAME output $OUT_PATH ($HASH) is missing from all caches."
                    break
                fi
            done <<< "$OUT_PATHS"

            if [ "$BUILD_IT" = false ]; then
                echo "Target $NAME: all required outputs are cached, skipping."
            fi
        fi
    fi

    if [ "$BUILD_IT" = true ]; then
        MISSING_TARGETS=$(echo "$MISSING_TARGETS" | jq ". + [$TARGET_JSON]")
    fi
done

COMPACT_TARGETS=$(echo "$MISSING_TARGETS" | jq -c .)
echo "Filtered targets: $COMPACT_TARGETS"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "targets=$COMPACT_TARGETS" >> "$GITHUB_OUTPUT"

  if [ "$COMPACT_TARGETS" = "[]" ]; then
    echo "has_targets=false" >> "$GITHUB_OUTPUT"
  else
    echo "has_targets=true" >> "$GITHUB_OUTPUT"
  fi
fi
