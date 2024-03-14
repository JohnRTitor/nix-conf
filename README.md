# My-NixOS-Config

Update
```
nix flake update
```
Switch to a new configuration
```
sudo nixos-rebuild switch --flake .
```
Switch + upgrade
```
sudo nixos-rebuild switch --flake . --upgrade
```
Check flake file and relevant configurations
```
nix flake check
```
