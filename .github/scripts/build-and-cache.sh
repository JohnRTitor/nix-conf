#!/usr/bin/env bash
set -euo pipefail

echo "::notice::Fetching list of packages to build"

# Get a list of packages defined in this flake
PKGS_LIST=$(nix flake show --json | jq -r '.packages."x86_64-linux" | keys | join(" ")')

# Add NixOS configuration attributes
for ATTR in $NIXOS_ATTRS_LIST; do
  PKGS_LIST+=" nixosConfigurations.$NIXOS_HOSTNAME.config.$ATTR"
done

for PKG in $NIXOS_PKGS_LIST; do
  PKGS_LIST+=" nixosConfigurations.$NIXOS_HOSTNAME.pkgs.$PKG"
done

# Write package list to step summary instead of notice
cat >> $GITHUB_STEP_SUMMARY << EOF
## 📦 Flake Attributes to Build

\`\`\`
$(printf '%s\n' $PKGS_LIST)
\`\`\`

EOF

echo "Fetching a list of VSCode extensions (configured using home-manager) to build"
vscodeExtensionNames=$(nix eval --json .#nixosConfigurations.$NIXOS_HOSTNAME.config.home-manager.users.$NIXOS_USER.programs.vscode.profiles.default.extensions --apply 'map (drv: drv.pname)' | jq -r '.[]')

# Write VSCode extensions to step summary
cat >> $GITHUB_STEP_SUMMARY << EOF
## 🔧 VSCode Extensions to Build

\`\`\`
$vscodeExtensionNames
\`\`\`

EOF

echo "::notice::Starting package build and cache push"
for PKG in $PKGS_LIST; do
  echo "Building package $PKG ..."
  nix build .#$PKG --print-out-paths --print-build-logs | cachix push $CACHIX_CACHE_NAME
done

vscodeExtensionDRVs=$(nix eval --json .#nixosConfigurations.$NIXOS_HOSTNAME.config.home-manager.users.$NIXOS_USER.programs.vscode.profiles.default.extensions --apply 'map (drv: drv.drvPath)' | jq -r '.[]')
echo "::notice::Starting VSCode extensions build and cache push"
for drv in $vscodeExtensionDRVs; do
  echo "Building vscode extension drv: $drv ..."
  nix build "${drv}^*" --print-build-logs --print-out-paths | cachix push $CACHIX_CACHE_NAME
done
