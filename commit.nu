#!/usr/bin/env nu

use std "path add"


path add /nix/var/nix/profiles/default/bin


def unwrap-or-else [val block] {
  if $val == null { do $block } else { $val }
}


def main [
  _msg?: string
  --type (-t): string
  --scope (-s): string
  --skip-ci (-c)
  ...rest
] {
  let msg: string = unwrap-or-else $_msg { input 'enter commit message: ' }

  let types = ["feat" "build" "ci" "fix" "refactor" "chore" "style"]
  let hosts: list<string> = (nix eval ".#nixosConfigurations" --apply builtins.attrNames --json --quiet | from json)
  let scopes = $hosts ++ ["qol" "treewide" "deploy" "commit" "deps"]

  let ty: string = unwrap-or-else $type { $types | input list 'choose type' --fuzzy }
  let scp: string = unwrap-or-else $scope { $scopes | input list 'choose scope' --fuzzy }
  let skipci = if $skip_ci == null { "" } else { " [skip ci]" }
  let commit_msg = $"($ty)\(($scp)\): ($msg)($skipci)"
  git commit -m $commit_msg ...$rest
}