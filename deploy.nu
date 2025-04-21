#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

def deploy [hostname: string] {
  let hooktitle = $"deploy @ ($hostname)"

  let start = date now
  secrets/deploy-webhook.nu $hooktitle $"=== deploying ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  let result = nix run $".#apps.nixinate.($hostname)" -L --show-trace | complete
  let end = date now

  let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($result | to text | into binary), secret: true}
  secrets/deploy-webhook.nu $hooktitle $"=== deployed ($hostname): finished ===\n\ntook ($end - $start)\n\nlog: ($paste_url)" $result.exit_code
}

def main [msg?: string] {
  try {
    nix run ".#dns" -- push
  } catch { |err|
    secrets/deploy-webhook.nu "dns" $"=== error pushing dns ===\n\n($err | to text)" 1
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

  deploy "wolumonde"
}