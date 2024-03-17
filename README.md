# My-NixOS-Config

This repository contains my personal NixOS configuration. It is tailored to my specific needs, for an AMD GPU and AMD CPU system. 

## Disclaimer

* I use an "unstable nixpkgs" system. Which provides bleeding edge packages for NixOS. 
* "unstable" is kind of a misnomer to be honest. Nix does a pretty good job at managing dependencies, that's why most things don't break. At least I have not faced any.
* I use a Hyprland setup with [these dotfiles](https://github.com/JohnRTitor/Hyprland-Dots), forked from [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots).
* Fonts, and themes need to be [seperately installed](https://github.com/JaKooLit/GTK-themes-icons). You may also decide to download [additional wallpapers](https://github.com/JaKooLit/Wallpaper-Bank/tree/main/wallpapers).

## Usage

Please note that this configuration is not meant to be used as is. It is highly personalized and may not suit your needs. However, you can easily modify it to fit your requirements by changing relevant parameters in `flake.nix`. 

For instance, you can change values like username, hostname, language, and timezone. 

To regenerate the hardware configuration, use the following command:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

## Commands

Check the flake file and relevant configurations:

```bash
nix flake check
```

Update the flake:

```bash
nix flake update
```

Switch to a new configuration:

```bash
sudo nixos-rebuild switch --flake .
```

Switch and upgrade:

```bash
sudo nixos-rebuild switch --flake . --upgrade
```

## Contributions

While I do not accept contributions or pull requests, you are welcome to suggest ideas to fix problems via the Issues tab. 

## Disclaimer

This configuration is provided as is, without warranty of any kind. Use of this configuration is at your own risk.

## License

This configuration is licensed under the Apache License 2.0. Please note that the software packages used within this configuration are licensed under their own respective terms. Be sure to check each one individually. Some of these packages are open source, while others are closed source and unfree.