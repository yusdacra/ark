{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = true;
    addKeysToAgent = "yes";
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
