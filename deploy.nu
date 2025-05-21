#!/usr/bin/env nu

use std "path add"
use std/log

path add /nix/var/nix/profiles/default/bin

cd $env.FLAKE

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

def upload-paste [content: any] {
  let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($content | to text | into binary), secret: true}
  return $paste_url
}

def time-block [block] {
  let start = date now
  let result = do $block
  let end = date now
  return {result: $result, elapsed: ($end - $start)}
}

def deploy [hostname: string] {
  log info $"start deploy host ($hostname)"
  let hooktitle = $"/($hostname)/deploy"

  webhook $hooktitle $"=== deploy for ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  log info $"build host ($hostname)"
  webhook $"($hooktitle)/build" $"=== building ($hostname) ==="
  let build_result = time-block { nh os build -H $hostname -- -L --show-trace | complete }
  let build_failed = $build_result.result.exit_code != 0
  webhook $"($hooktitle)/build" $"=== built ($hostname) ===\n\ntook ($build_result.elapsed)\n\nlog: (upload-paste $build_result.result)" $build_result.result.exit_code $build_failed

  if $build_failed {
    return
  }

  log info $"deploy host ($hostname)"
  webhook $"($hooktitle)/build" $"=== deploying ($hostname) ==="
  let deploy_result = time-block { nix run $".#apps.nixinate.($hostname)" -L --show-trace | complete }
  let deploy_failed = $deploy_result.result.exit_code != 0
  webhook $"($hooktitle)/build" $"=== deployed ($hostname) ===\n\ntook ($deploy_result.elapsed)\n\nlog: (upload-paste $deploy_result.result)" $deploy_result.result.exit_code $deploy_failed

  if $deploy_failed {
    return
  }

  webhook $hooktitle $"=== deploy for ($hostname): finished ===" 0 true
}

def update-input [input: string] {
  try { git stash }
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
  try { git stash pop }
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