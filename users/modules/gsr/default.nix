{config, lib, pkgs, ...}:
let
  shotDir = "${config.home.homeDirectory}/shots";
in
{
  systemd.user.services.gsr-replay = {
    Unit = {
      Description = "gpu screen recorder replay";
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${shotDir}";
      ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w screen -f 60 -a default_output -k av1 -c mp4 -bm cbr -q 40000 -r 45 -o ${shotDir}";
      Restart = "on-failure";
      RestartSec = 5;
      KillSignal = "SIGKILL";
      SuccessExitStatus = "SIGKILL";
    };
  };
}
