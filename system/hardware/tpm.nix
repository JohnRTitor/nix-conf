{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:
lib.mkIf systemSettings.tpm {
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  # security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  # users.users.${userSettings.username}.extraGroups = ["tss"]; # tss group has access to TPM devices
}
