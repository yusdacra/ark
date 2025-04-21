#!/usr/bin/env nu

nix flake update

git add .
git commit -m "chore: update flake dependencies (deploy) [skip ci]"
git push

nix run .#apps.nixinate.wolumonde -L --show-trace
