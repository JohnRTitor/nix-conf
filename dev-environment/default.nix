{ ... }:
{
    # Configure the build environment
    imports = [
        ./adb-toolchain.nix
        ./c-toolchain.nix
        ./php.nix
    ];
}