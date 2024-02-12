{
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    charger = {
      governor = "powersave";
      scaling_min_freq = 600000;
      scaling_max_freq = 3000000;
      turbo = "off";
    };
    battery = {
      governor = "powersave";
      scaling_min_freq = 400000;
      scaling_max_freq = 2000000;
      turbo = "off";
    };
  };
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_AC = "";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "";
  };
}
