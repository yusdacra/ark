#!/usr/bin/env nu

use std "path add"
use std/log

path add /nix/var/nix/profiles/default/bin

cd $env.NH_FLAKE

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

  if $exit_code == 0 or $exit_code == null {
    log info $content
  } else {
    log error $content
  }
  # http post --content-type application/json $"https://discord.com/api/webhooks/($env.WEBHOOK_ID)/($env.WEBHOOK_TOKEN)" $msg
}

def upload-paste []: any -> string {
  # let paste_url = http post --content-type multipart/form-data "https://0x0.st" {file: ($in | to text | into binary), secret: true}
  # return $paste_url
  return ""
}

def time-block [block]: nothing -> record {
  let start = date now
  let result = do $block
  let end = date now
  return {result: $result, elapsed: ($end - $start)}
}

let ips = {
  wolumonde: "23.88.101.188",
}

def deploy [hostname: string] {
  log info $"start deploy host ($hostname)"
  let hooktitle = $"/($hostname)/deploy"

  webhook $hooktitle $"=== deploy for ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  def run_step [action: string, block]: nothing -> bool {
    webhook $"($hooktitle)/($action)" $"=== ($action) ($hostname) started ==="
    let result = time-block { do $block | tee -e {print -r} | tee {print -r} | complete }
    let failed = $result.result.exit_code != 0
    webhook $"($hooktitle)/($action)" $"=== ($action) ($hostname) is done ===\n\ntook ($result.elapsed)\n\nlog: ($result.result | upload-paste)" $result.result.exit_code $failed
    return $failed
  }

  let result_dir = mktemp -d | path join "result"
  let build_cmd = {nh os build --no-nom -H $hostname -o $result_dir -- -L --show-trace}
  if (run_step "build" $build_cmd) {
    return
  }
  let result_link = readlink $result_dir

  # TODO: dont hardcode user
  let target = $"root@($ips | get $hostname)"
  let copy_cmd = {nix copy --to $"ssh://($target)" $result_link}
  if (run_step "copy to" $copy_cmd) {
    return
  }

  let activate_cmd = {ssh $target $"sudo '($result_link)/bin/switch-to-configuration' 'switch'"}
  if (run_step "activate" $activate_cmd) {
    return
  }

  webhook $hooktitle $"=== deploy for ($hostname): finished ===" 0 true
}

def update-input [input: string] {
  let stashed = try {
    let stash_result = git stash | complete
    $stash_result.stdout | str contains "Saved working directory"
  } catch {
    false
  }
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
  } else {
    try {
      git restore .
    }
  }
  if $stashed {
    try {
      git stash pop
    }
  }
}

def main [hostname: string = "wolumonde"] {
  webhook "deploy" "=== started deploying all ==="

  ["blog" "skeetdeck" "brl" "limbusart"]
    | each {|input| update-input $input}

  try {
    log info "trying to update dns records"
    nix run ".#dns" -- push
  } catch { |err|
    webhook "dns" $"=== error pushing dns ===\n\n($err.msg | to text)" 1
  }

  deploy $hostname
}
