#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

def main [msg?: string] {
  nix flake update

  try {
    git add .
    let commit_msg = if $msg == null {
      "chore: update flake dependencies (deploy)"
    } else {
      $msg
    }
    git commit -m $"($commit_msg) [skip ci]"
    git push
  }

  let start = date now
  secrets/deploy-webhook.nu $"deploying wolumonde: started"

  let result = nix run ".#apps.nixinate.wolumonde" -L --show-trace | complete
  let end = date now

  secrets/deploy-webhook.nu $"deployed wolumonde: finished, took ($end - $start)\n\n($result | to text)" $result.exit_code
}