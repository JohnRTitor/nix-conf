{
  ...
}:

{
  swapDevices = [
    {
      device = "/dev/lvm-pool/swap";
      options = [
        "defaults"
        "nofail"
      ];
      randomEncryption = {
        enable = true;
        keySize = 512;
      };
    }
  ];
}
