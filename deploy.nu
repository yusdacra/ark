#!/usr/bin/env nu

use std "path add"

path add /nix/var/nix/profiles/default/bin

nix flake update

git add .
git commit -m "chore: update flake dependencies (deploy) [skip ci]"
git push

nix run .#apps.nixinate.wolumonde -L --show-trace
