{
  services.tlp = {
    enable = true;
    settings = {
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
      RADEON_DPM_STATE_ON_AC = "balanced";
      RADEON_DPM_STATE_ON_BAT = "battery";
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      NMI_WATCHDOG = 0;
      CPU_DRIVER_OPMODE_ON_AC="active";
      CPU_DRIVER_OPMODE_ON_BAT="active";
      CPU_ENERGY_PERF_POLICY_ON_AC="balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT="balance_power";
      CPU_SCALING_GOVERNOR_ON_AC="powersave";
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      SOUND_POWER_SAVE_ON_AC=1;
      SOUND_POWER_SAVE_ON_BAT=1;
      RUNTIME_PM_ON_AC="auto";
      RUNTIME_PM_ON_BAT="auto";
    };
  };
}
