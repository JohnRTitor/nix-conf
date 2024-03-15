# My-NixOS-Config

This repository contains my personal NixOS configuration. It is tailored to my specific needs, for an AMD GPU and AMD CPU system. 

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