{ ... }: {
  # ─────────────────────────────────────────────────────────────
  # ZRAM configuration
  # ─────────────────────────────────────────────────────────────
  # ZRAM creates a compressed swap device in RAM. On a 16 GB system this
  # gives us up to ~16 GB of compressed swap, which effectively extends
  # usable memory to ~24-28 GB depending on compressibility.
  zramSwap = {
    enable = true;
    # 100% of physical RAM as the maximum ZRAM device size.
    # Actual physical memory consumed depends on compression ratio (~2-3x).
    memoryPercent = 100;
  };

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

  # ─────────────────────────────────────────────────────────────
  # systemd-oomd: pressure-based safety net
  # ─────────────────────────────────────────────────────────────
  # Strategy:
  #   - oomd acts as a last-resort safety net, not a constant killer.
  #   - Pressure-based monitoring (PSI) is the primary trigger, not swap usage.
  #   - With ZRAM, "swap full" just means compressed RAM is saturated,
  #     which happens differently than with disk swap. Pressure-based
  #     thresholds are more accurate indicators of actual system distress.
  #   - Background/heavy workloads (ollama, odysseus) are killed first.
  #   - System services are killed before user desktop apps.
  #   - Desktop-critical infrastructure is fully protected from oomd.
  #
  # Kill priority (first to last):
  #   1. Heavy background workloads (ollama, odysseus) — OOMScoreAdjust +200/+150
  #   2. system.slice services — 80% pressure / 40s
  #   3. user.slice apps — 70% pressure / 25s
  #   4. Root fallback — 90% pressure (last resort)
  #   5. NEVER: logind, greetd, network, ssh, dbus, scx, audio, compositor
  #            shell (noctalia), polkit, idle daemon

  systemd.oomd = {
    enable = true;
    enableUserSlices = true;
    enableSystemSlice = true;
    enableRootSlice = true;

    settings.OOM = {
      # Global swap safety net. Set high because ZRAM swap fills up
      # differently from disk swap — it saturates as a function of
      # compression ratio, not I/O bandwidth. 95% gives oomd room to
      # intervene before the kernel OOM killer fires, without triggering
      # prematurely during normal ZRAM utilisation.
      SwapUsedLimit = "80%";

      # Default pressure thresholds for any monitored slice that doesn't
      # specify its own. These are conservative: 60% pressure sustained
      # for 30 seconds means the system is genuinely struggling.
      DefaultMemoryPressureLimit = "60%";
      DefaultMemoryPressureDurationSec = "30s";
    };
  };

  # Keep cgroup accounting on so oomd and memory controls have full visibility.
  systemd.settings.Manager = {
    DefaultCPUAccounting = true;
    DefaultIOAccounting = true;
    DefaultMemoryAccounting = true;
    DefaultTasksAccounting = true;
  };

  # ─────────────────────────────────────────────────────────────
  # Slice-level oomd policies
  # ─────────────────────────────────────────────────────────────

  # Root slice: pressure-based monitoring only.
  # On a ZRAM-only system, ManagedOOMSwap=kill on the root slice is
  # dangerous — ZRAM swap can fill up rapidly once the compression ratio
  # degrades, and root-level swap-kill would non-selectively terminate
  # processes across the entire system. Pressure monitoring is safer and
  # more predictable here.
  systemd.slices."-".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "90%";
  };

  # system.slice: daemons and services.
  # These should be killed before user apps. The relatively high pressure
  # limit (80%) and long duration (40s) mean only sustained heavy pressure
  # triggers action — transient build spikes or database cache flushes
  # won't cause premature kills.
  systemd.slices.system.sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "80%";
    ManagedOOMMemoryPressureDurationSec = "40s";
  };

  # user.slice: desktop apps, browsers, games, editors.
  # Use a higher threshold and longer duration than system.slice so that
  # oomd prefers to reclaim system services before touching user apps.
  # 70% pressure for 25 seconds is still protective but won't fire during
  # normal browser/game memory churn.
  systemd.slices.user.sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "70%";
    ManagedOOMMemoryPressureDurationSec = "25s";
  };

  # ─────────────────────────────────────────────────────────────
  # Critical system service protection
  # ─────────────────────────────────────────────────────────────
  # Services with ManagedOOMPreference=omit are invisible to oomd.
  # MemoryMin/MemoryLow provide cgroup-level reclaim protection so the
  # kernel itself avoids reclaiming these pages under pressure.
  # OOMScoreAdjust protects against the kernel OOM killer (separate from oomd).

  # Login manager — losing this kills the entire graphical session.
  # systemd-logind manages seats, sessions, and user state.
  systemd.services.systemd-logind.serviceConfig = {
    MemoryMin = "32M";
    MemoryLow = "64M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-1000";
  };

  # Display manager — cosmic-greeter uses greetd as its backend.
  # Losing the greeter prevents session recovery after logout.
  systemd.services.greetd.serviceConfig = {
    MemoryLow = "128M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-900";
  };

  # Network — losing connectivity mid-session is extremely disruptive,
  # and many desktop apps depend on network availability.
  systemd.services.NetworkManager.serviceConfig = {
    MemoryMin = "64M";
    MemoryLow = "128M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-900";
  };

  # SSH — remote access lifeline for debugging.
  systemd.services.sshd.serviceConfig = {
    MemoryMin = "32M";
    MemoryLow = "64M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-900";
  };

  # D-Bus broker — the entire desktop session depends on the message bus.
  # Losing dbus kills portals, authentication prompts, notifications,
  # and most IPC between desktop components.
  systemd.services.dbus-broker.serviceConfig = {
    MemoryMin = "32M";
    MemoryLow = "64M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-950";
  };

  # scx scheduler — scx_lavd manages CPU scheduling for responsiveness.
  # If killed, the system falls back to the default scheduler, which
  # can cause hitches until the next reboot.
  systemd.services.scx.serviceConfig = {
    MemoryMin = "16M";
    MemoryLow = "32M";
    ManagedOOMPreference = "omit";
    OOMScoreAdjust = "-800";
  };

  # ─────────────────────────────────────────────────────────────
  # Critical user service protection (desktop session infrastructure)
  # ─────────────────────────────────────────────────────────────
  # These run in the user session via systemd --user.
  # User services cannot use MemoryMin/MemoryLow (those require the
  # parent slice to delegate memory accounting). OOMScoreAdjust is the
  # primary protection mechanism here.

  # PipeWire — the audio server. Killing it causes pops, hangs, and
  # often requires a session restart to recover. Uses very little memory.
  systemd.user.services.pipewire.serviceConfig = {
    OOMScoreAdjust = "-800";
  };

  # WirePlumber — PipeWire's session/policy manager. Audio routing
  # breaks completely without it.
  systemd.user.services.wireplumber.serviceConfig = {
    OOMScoreAdjust = "-800";
  };

  # ─────────────────────────────────────────────────────────────
  # Note: The following specific user services are configured in Home Manager
  # to correctly apply to the user's systemd instance instead of the system config.
  # Check their respective files for OOMScoreAdjust configurations:
  # - noctalia (OOMScoreAdjust = -900)
  # - pyprland (OOMScoreAdjust = -500)
  # - pantheon-agent-polkit (OOMScoreAdjust = -700)
  # - hypridle (OOMScoreAdjust = -400)
  # ─────────────────────────────────────────────────────────────

  # ─────────────────────────────────────────────────────────────
  # Heavy / background workloads (preferred kill candidates)
  # ─────────────────────────────────────────────────────────────
  # These are memory-heavy services that should be sacrificed to protect
  # desktop responsiveness. Positive OOMScoreAdjust makes the kernel OOM
  # killer prefer them. MemoryHigh/MemoryMax caps prevent them from
  # crowding out the rest of the system.

  # Ollama (local LLM inference) — can consume massive memory.
  # NOTE: models > 12GB VRAM will offload to CPU/RAM and can destabilize
  # the system (see ai-models.nix). MemoryMax is a hard safety cap.
  systemd.services.ollama.serviceConfig = {
    MemoryHigh = "6G";
    MemoryMax = "10G";
    OOMScoreAdjust = "800";
  };

  # Odysseus (AI web UI for Ollama) — Python-based, can grow large
  # with document processing and embedding caches.
  systemd.services.odysseus.serviceConfig = {
    MemoryHigh = "2G";
    MemoryMax = "4G";
    OOMScoreAdjust = "150";
  };

  # Uncomment and tune as needed:
  #
  # systemd.services.docker.serviceConfig = {
  #   MemoryLow = "256M";
  #   OOMScoreAdjust = "-100";
  # };
  #
  # systemd.services.podman.serviceConfig = {
  #   MemoryLow = "128M";
  #   OOMScoreAdjust = "-100";
  # };
  #
  # systemd.services.postgresql.serviceConfig = {
  #   MemoryMin = "256M";
  #   MemoryLow = "512M";
  #   ManagedOOMPreference = "omit";
  #   OOMScoreAdjust = "-200";
  # };
}
