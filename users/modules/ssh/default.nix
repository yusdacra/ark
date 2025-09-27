{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
        forwardAgent = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        compression = true;
        hashKnownHosts = true;
        addKeysToAgent = "yes";
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
    };
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
  services.ssh-agent.enable = true;
}
