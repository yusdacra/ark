{
  services.tlp = {
    enable = true;
    settings = {
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
      RADEON_DPM_STATE_ON_AC = "balanced";
      RADEON_DPM_STATE_ON_BAT = "battery";
      PCIE_ASPM_ON_AC = "powersave";
      PCIE_ASPM_ON_BAT = "powersupersave";
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      NMI_WATCHDOG = 0;
    };
  };
}
