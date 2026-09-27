{ ... }: {
  # ─────────────────────────────────────────────────────────────
  # ZRAM configuration
  # ─────────────────────────────────────────────────────────────
  # ZRAM creates a compressed swap device in RAM.
  # Set to 150% of physical memory to provide a massive virtual memory buffer
  # required to absorb heavy parallel compilation spikes (ie, during Android builds).
  # Note: Setting this to 150% does NOT mean it pre-allocates or costs 150% of
  # actual RAM. ZRAM is entirely dynamic; it consumes exactly 0 bytes at boot
  # and only scales up as pages are swapped out. Because build code and artifacts
  # yield an excellent compression ratio (typically 2:1 to 4:1), it only consumes
  # roughly ~1 byte of physical RAM for every 2 to 4 bytes of data compressed inside it.
  # On a 16 GB system, this provisions a ~24 GB ZRAM swap space, extending
  # theoretical usable memory space up to ~32-36 GB depending on code compressibility.
  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  # DO NOT ENABLE ZSWAP IF ZRAM IS ACTIVE.
  # Because zswap acts as a cache in front of swap devices, enabling both causes
  # the kernel to waste CPU cycles double-compressing the same memory pages.
  # Furthermore, zswap will prematurely flush pages to zram, causing high reclaim overhead.
  boot.kernelParams = [
    "zswap.enabled=0"
  ];

  boot.kernel.sysctl = {
    # With ZRAM-only swap, high swappiness is correct:
    # it tells the kernel to prefer compressing pages into ZRAM over
    # dropping file caches, which keeps applications responsive.
    "vm.swappiness" = 200;
    # Disable watermark boosting — unnecessary with ZRAM and can cause
    # premature direct reclaim.
    "vm.watermark_boost_factor" = 0;
    # Wider watermark band allows kswapd to start earlier and work longer,
    # reducing direct reclaim stalls in foreground tasks.
    "vm.watermark_scale_factor" = 125;
    # Disable readahead clustering for swap — ZRAM is random-access RAM,
    # not a spinning disk, so multi-page readahead wastes decompression work.
    "vm.page-cluster" = 0;
  };
}
