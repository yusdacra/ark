{...}: {
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = true;
    userKnownHostsFile = "~/.local/share/ssh/known-hosts";
    # Only needed for darcs hub
    # extraConfig = ''
    #   Host hub.darcs.net
    #      ControlMaster no
    #      ForwardAgent no
    #      ForwardX11 no
    #      Ciphers +aes256-cbc
    #      MACs +hmac-sha1
    # '';
  };
}
