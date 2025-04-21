#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

source-env secrets/deploy-webhook.nu

def webhook [title: string, content: string, exit_code?: number] {
  let type = if $exit_code == null { "⌛" } else if $exit_code == 0 { "✔️" } else { "❌" }
  let msg = {
    embeds: [{
      description: $content,
      title: $"($type) /($title)/",
      footer: {
        text: $"(date now) \((sys host | get hostname)\)",
      }
    }]
  }
  http post --content-type application/json $"https://discord.com/api/webhooks/($env.WEBHOOK_ID)/($env.WEBHOOK_TOKEN)" $msg
}

def deploy [hostname: string] {
  let hooktitle = $"/($hostname)/deploy"

  let start = date now
  webhook $hooktitle $"=== deploying ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  let result = nix run $".#apps.nixinate.($hostname)" -L --show-trace | complete
  let end = date now

  let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($result | to text | into binary), secret: true}
  webhook $hooktitle $"=== deployed ($hostname): finished ===\n\ntook ($end - $start)\n\nlog: ($paste_url)" $result.exit_code
}

def main [msg?: string] {
  try {
    nix run ".#dns" -- push
  } catch { |err|
    webhook "dns" $"=== error pushing dns ===\n\n($err | to text)" 1
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