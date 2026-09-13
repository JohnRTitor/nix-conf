# GitHub Actions Cache Targets

The `cache-targets.toml` file contains the build targets for the caching workflow (`cache.yml`). 
This allows us to selectively build and push large or important derivations to Cachix so they can be reused.

## Parameters

Each target is defined as a table `[[targets]]`. Below are the supported properties:

- **`group`** *(string, required)*: The category of the target.
  - Examples: `"nixos_config_attribute"`, `"nixos_package"`, `"flake_package"`, `"vscode_extensions"`, `"remote_flake"`.
- **`name`** *(string, required)*: The attribute path, package name, or target identifier.
  - Example: `"boot.kernelPackages.kernel"`, `"zed-editor"`, `"xdg-desktop-portal-gtk4"`.
- **`hostname`** *(string, optional)*: The target NixOS hostname (required for `nixos_config_attribute` or `nixos_package` groups).
  - Example: `"Ainz-NIX"`.
- **`user`** *(string, optional)*: The username associated with the target, often used for Home Manager packages or user-specific configurations (like `vscode_extensions`).
- **`large_build`** *(boolean, optional)*: Set this to `true` if the package takes up a significant amount of disk space to build (e.g., the Linux kernel). When `true`, the CI will run a specialized `setup-nix` composite action that aggressively reclaims runner disk space before building. If `false` or omitted, it defaults to the much faster Determinate Systems Nix installer.
