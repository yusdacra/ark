#!/usr/bin/env bash

set -x

nix flake update

git commit -m "chore: update flake dependencies (deploy) [skip ci]"; git push

nix run .#apps.nixinate.wolumonde -L --show-trace
