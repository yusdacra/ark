{ pkgs, ... }:
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

  # FIDO2/YubiKey (sk-ssh-ed25519) keys created with `verify-required` need a
  # PIN prompt at signing time. The ssh-agent has no TTY, so it must use an
  # SSH_ASKPASS helper. NixOS sets SSH_ASKPASS="" globally whenever
  # programs.ssh.enableAskPassword is false (true when there's no X server, as
  # with a pure-Wayland/niri session); that empty value gets imported into the
  # user systemd manager and the agent, so signing fails with
  # "sign_and_send_pubkey: signing failed ... agent refused operation".
  # A unit-level Environment= overrides the inherited empty value.
  #
  # Note: gcr's gcr4-ssh-askpass is NOT a usable generic SSH_ASKPASS — it
  # exits with "this program is not meant to be run directly" unless spawned by
  # gcr-ssh-agent. x11-ssh-askpass is a standalone askpass and works fine here
  # via the xwayland-satellite Xwayland :0 that the niri session runs.
  systemd.user.services.ssh-agent.Service.Environment = [
    "SSH_ASKPASS=${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass"
    "SSH_ASKPASS_REQUIRE=prefer"
  ];
}
