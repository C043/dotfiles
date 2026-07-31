{ ... }:

{
  # Full Magic SysRq: kernel default (16) only allows sync, so Alt+SysRq+F
  # (OOM kill) and REISUB are unavailable during a freeze.
  boot.kernel.sysctl."kernel.sysrq" = 1;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Uncomment if nixos-rebuild itself is what exhausts RAM.
  # nix.settings.max-jobs = 4;
}
