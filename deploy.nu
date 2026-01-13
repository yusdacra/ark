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
  # let paste_url = http post -H ["user-agent" "gaze.systems terra deploy"] --content-type multipart/form-data "https://0x0.st" {file: ($in | to text | into binary), secret: true}
  # return $paste_url
  return ""
}

def time-block [block]: nothing -> record {
  let start = date now
  let result = do $block
  let end = date now
  return {result: $result, elapsed: ($end - $start)}
}

let hosts = {
  dzwonek: {
    type: "nixos",
    user: "root",
    addr: "94.237.26.47",
  },
  volsinii: {
    type: "nixos",
    user: "root",
    addr: "199.71.188.53",
  },
  trimounts: {
    type: "nixos",
    user: "root",
    addr: "159.195.58.28",
  },
}

def deploy [hostname: string] {
  log info $"start deploy host ($hostname)"
  let hooktitle = $"/($hostname)/deploy"
  let hostcfg = $hosts | get $hostname

  webhook $hooktitle $"=== deploy for ($hostname): started ===\n\n(sys disks | to text)\n\n(sys mem | to text)"

  def run_step [action: string, block]: nothing -> bool {
    webhook $"($hooktitle)/($action)" $"=== ($action) ($hostname) started ==="
    let result = time-block { do $block | tee -e {print -r} | tee {print -r} | complete }
    let failed = $result.result.exit_code != 0
    webhook $"($hooktitle)/($action)" $"=== ($action) ($hostname) is done ===\n\ntook ($result.elapsed)\n\nlog: ($result.result | upload-paste)" $result.result.exit_code $failed
    return $failed
  }

  let result_dir = mktemp -d | path join "result"
  let build_cmd = {
    match $hostcfg.type {
      "nixos" => {nh os build --no-nom -H $hostname -o $result_dir -- -L --show-trace}
      "home" => {nh home build --no-nom -c $hostname -o $result_dir -- -L --show-trace}
    }
  }
  if (run_step "build" $build_cmd) {
    return
  }
  let result_link = readlink $result_dir

  let target = $"($hostcfg.user)@($hostcfg.addr)"
  let copy_cmd = {nix copy -s --to $"ssh://($target)" $result_link}
  if (run_step "copy to" $copy_cmd) {
    return
  }

  let activate_cmd = {
    let cmd = match $hostcfg.type {
      "nixos" => $"sudo '($result_link)/bin/switch-to-configuration' 'switch'",
      "home" => $"($result_link)/activate",
    }
    ssh $target $cmd
  }
  if (run_step "activate" $activate_cmd) {
    return
  }

  webhook $hooktitle $"=== deploy for ($hostname): finished ===" 0 true
}

def update-inputs []: list<string> -> bool {
  let inputsText = $in | str join ", "
  let stashed = try {
    let stash_result = git stash | complete
    $stash_result.stdout | str contains "Saved working directory"
  } catch {
    false
  }
  log info $"trying to update inputs ($inputsText)"
  let result = nix run .#nvfetcher -- -f $"\(($in | str join '|')\)" | complete
  let is_ok = ($result.stdout | str contains "Changes:")
  if $is_ok {
    let changes_content = $result.stdout | lines | skip until {|line| $line | str contains "Changes:"} | skip 1 | str join "\n"
    webhook $"/inputs" $"=== updated inputs ===\n\n($changes_content)" $result.exit_code
  }
  if $is_ok {
    # try committing flake updates
    try {
      git add _sources
      git commit -m "chore(nix): update inputs [skip ci]"
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
  $is_ok
}

def main [hostname: string = "wolumonde", --only-deploy (-d)] {
  webhook "deploy" "=== started deploying ==="

  mut inputs_updated = false
  if $only_deploy == false {
    $inputs_updated = ["blog" "limbusart" "nsid-tracker" "tangled"] | update-inputs
    try {
      log info "trying to update dns records"
      nix run ".#dns" -- push
    } catch { |err|
      webhook "dns" $"=== error pushing dns ===\n\n($err.msg | to text)" 1
    }
  }

  if $hostname == "all" {
    $hosts | columns | each {|host| deploy $host}
  } else {
    deploy $hostname
  }

  if $inputs_updated {
    try { git push }
  }
}
