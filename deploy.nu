#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

nix flake update

try {
  git add .
  git commit -m "chore: update flake dependencies (deploy) [skip ci]"
  git push
}

let start = date now
secrets/deploy-webhook.nu $"deploying wolumonde: started @ ($start)"

let result = nix run ".#apps.nixinate.wolumonde" -L --show-trace | complete
let end = date now

if result.exit_code == 0 {
  secrets/deploy-webhook.nu $"deployed wolumonde: finished @ ($end); took ($end - $start)"
} else {
  secrets/deploy-webhook.nu $"error deploying wolumonde:\n($result | to json)"
}