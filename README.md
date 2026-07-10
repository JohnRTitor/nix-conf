# My-NixOS-Config

This repository contains my personal NixOS configuration. It is tailored to my specific needs, for an AMD GPU and AMD CPU system.
You are welcomed to borrow this config fully or in chunks.

## Disclaimer

- I use an "unstable nixpkgs" system. Which provides bleeding edge packages for NixOS.
- "unstable" is kind of a misnomer to be honest. Nix does a pretty good job at managing dependencies, that's why most things don't break. At least I have not faced any.
- I use a Hyprland setup with [these dotfiles](https://github.com/JohnRTitor/Hyprland-Dots), forked from [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots).
- Fonts, and themes need to be [seperately installed](https://github.com/JaKooLit/GTK-themes-icons). You may also decide to download [additional wallpapers](https://github.com/JaKooLit/Wallpaper-Bank/tree/main/wallpapers).
- This configuration is provided as is, without warranty of any kind. Use of this configuration is at your own risk.

## Usage

Please note that this configuration is not meant to be used as is. It is highly personalized and may not suit your needs. However, you can easily modify it to fit your requirements by changing relevant parameters in [preferences.nix](./preferences.nix).

For instance, you can change values like username, hostname, language, and timezone.

To regenerate the hardware configuration, use the following command:

```bash
sudo nixos-generate-config --show-hardware-config > ./system/hardware/hardware-configuration.nix
```

## Repository Structure

This repository is organized into several modules and directories to keep the configuration clean and manageable:

- **`flake/`**: Contains the core Flake configuration (`default.nix`). It orchestrates inputs (like nixpkgs, home-manager, stylix), defines system architectures, and maps custom package derivations.
- **`hosts/`**: Contains host-specific configurations.
  - `Ainz-NIX.nix`: The primary configuration file for the host, importing required system modules and setting host-specific overrides.
- **`modules/`**: The core of the NixOS configuration, heavily modularized:
  - **`home-manager/`**: User-specific environments and dotfiles.
    - `common/`: Shared home-manager configs across different users or hosts.
    - `user-config/`: Specific configurations for individual user profiles.
  - **`system/`**: System-wide NixOS configurations.
    - `boot/`: Kernel parameters, initrd, and bootloader settings.
    - `hardware/`: Hardware-specific configurations, including graphics (AMD), audio, bluetooth, and TPM.
    - `hyprland/`: Configuration for the Hyprland window manager and associated tools.
    - `services/`: System services (e.g., databases, virtualisation, flatpak).
    - `programs/` & `shell/`: System-wide installed programs, terminal emulators, and shell environments (Zsh).
    - `network.nix`, `users.nix`, `stylix.nix`: Modular files for specific system domains.
  - **`pkgs-configuration/`**: Centralized lists for easy package management.
    - `global-packages.nix`: Packages installed system-wide.
    - `user-packages/`: Packages installed only for specific users.
    - `flatpak-packages.nix`: Declarative Flatpak definitions.
  - **`lib/`**: Custom library functions and NixOS option definitions (`options-definitions.nix`) that enable custom module switches.
  - **`modules-overlays/`**: Nixpkgs overlays applied across the system to modify packages or add custom patches.
  - **`preferences.nix` **: Core configuration files for easy tweaking. They contain boolean switches, username, locale, themes, and default app preferences.
- **`packages/`**: Custom Nix package derivations created for this system.
  - Includes tools like `adminneo-with-theme`, repackaged `google-chrome`, `fhs-shell`, `gparted-wrapper`, and custom scripts.
- **`wallpapers/`**: Contains desktop wallpapers, integrated with Stylix for system-wide dynamic color scheme generation.

## Commands

Check the flake file and relevant configurations:

```bash
nix flake check
```

Update the flake.lock and update packages:

```bash
nix flake update
```

Switch/update to a new configuration:

```bash
sudo nixos-rebuild switch --flake .#Ainz-NIX
```

## Automated Caching

This repository uses GitHub Actions and Cachix to automatically build and cache large or frequently changing packages.

Targets are defined in `.github/cache-targets.toml`. You can specify individual packages, NixOS configuration attributes (like custom kernels or desktop environments), and VSCode extensions.
By defining them in the TOML file, CI will build them in parallel and push the results to Cachix. When you switch to a new configuration locally using `nixos-rebuild`, it will pull the pre-compiled binaries from the cache instead of compiling them on your machine, saving significant time.

### Setup Requirements

For the GitHub Actions workflow to push to your Cachix cache successfully, you must configure the following in your repository settings:

- **GitHub Repository Secret**: Create a secret named `CACHIX_AUTH_TOKEN` containing your Cachix authentication token.
- **Workflow Variable**: Update the `CACHIX_CACHE_NAME` environment variable inside `.github/workflows/cache.yml` to match your actual Cachix cache name.

## Contributions

While I do not accept contributions or pull requests, you are welcome to suggest ideas to fix problems via the Issues tab.

## License

This configuration is licensed under the Apache License 2.0. Please note that the software packages used within this configuration are licensed under their own respective terms. Be sure to check each one individually. Some of these packages are open source, while others are closed source and unfree.
