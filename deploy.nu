#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

def main [msg?: string] {
  nix flake update

  try {
    nix run ".#dns" -- push
  }

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

  let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($result | to text | into binary), secret: true}
  secrets/deploy-webhook.nu $"deployed wolumonde: finished, took ($end - $start)\n\nlog: ($paste_url)" $result.exit_code
}