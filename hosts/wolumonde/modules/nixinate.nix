{...}: {
  _module.args.nixinate = {
    host = "gaze.systems";
    sshUser = "root";
    buildOn = "local"; # valid args are "local" or "remote"
    substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
    hermetic = true;
  };
}
