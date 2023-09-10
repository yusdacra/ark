{
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    charger = {
      governor = "powersave";
      scaling_min_freq = 1500000;
      scaling_max_freq = 3000000;
      turbo = "auto";
    };
    battery = {
      governor = "powersave";
      scaling_min_freq = 900000;
      scaling_max_freq = 1800000;
      turbo = "auto";
    };
  };
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_AC = "";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "";
  };
}
