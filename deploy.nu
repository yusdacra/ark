#!/usr/bin/env nu

use std "path add"
use std/log

path add /nix/var/nix/profiles/default/bin

# load webhook secrets
rage -d -i ./ssh_key ./secrets/deployWebhook.age | from toml | load-env

def webhook [title: string, content: string, exit_code?: number, ping?: bool = false] {
  let type = if $exit_code == null { "⌛" } else if $exit_code == 0 { "✔️" } else { "❌" }
  let msg = {
    content: (if $ping { "hey <@853064602904166430>!" } else { "" }),
    embeds: [{
      description: $content,
      title: $"($type) /($title)/",
      footer: {
        text: $"(date now) \((sys host | get hostname)\)",
      }
    }]
  }

  log debug "posting webhook...."
  http post --content-type application/json $"https://discord.com/api/webhooks/($env.WEBHOOK_ID)/($env.WEBHOOK_TOKEN)" $msg
}

def deploy [hostname: string] {
  log info $"trying to deploy host ($hostname)"
  let hooktitle = $"/($hostname)/deploy"

  let start = date now
  webhook $hooktitle $"=== deploying ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  let result = nix run $".#apps.nixinate.($hostname)" -L --show-trace | complete
  let end = date now

  let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($result | to text | into binary), secret: true}
  webhook $hooktitle $"=== deployed ($hostname): finished ===\n\ntook ($end - $start)\n\nlog: ($paste_url)" $result.exit_code true
}

def update-input [input: string] {
  log info $"trying to update input ($input)"
  let result = nix flake update $input | complete
  let is_ok = ($result.stderr | str contains "Updated input")
  let is_err = ($result.exit_code != 0)
  if $is_ok or $is_err {
    webhook $"/inputs/($input)" $"=== updated input ($input) ===\n\n($result.stderr)" $result.exit_code
  }
  if $is_ok {
    # try committing flake updates
    try {
      git add flake.lock
      let commit_msg = $"chore\(nix\): update input ($input) [skip ci]"
      git commit -m $commit_msg
      git push
    }
  }
}

def main [] {
  webhook "deploy" "=== started deploying all ==="

  update-input "blog"

  try {
    log info "trying to update dns records"
    nix run ".#dns" -- push
  } catch { |err|
    webhook "dns" $"=== error pushing dns ===\n\n($err.msg | to text)" 1
  }

  deploy "wolumonde"
}