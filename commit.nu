#!/usr/bin/env nu

use std "path add"


path add /nix/var/nix/profiles/default/bin


def unwrap-or-else [val block] {
  if $val == null { do $block } else { $val }
}


def main [
  msg: string
  --type (-t): string
  --scope (-s): string
  ...rest
] {
  let types = ["feat" "build" "ci" "fix" "refactor" "chore" "style"]
  let hosts: list<string> = (nix eval ".#nixosConfigurations" --apply builtins.attrNames --json --quiet | from json)

  let ty: string = unwrap-or-else $type { $types | input list 'choose type' --fuzzy }
  let scp: string = unwrap-or-else $scope { $hosts | input list 'choose host' --fuzzy }
  let commit_msg = $"($ty)\(($scp)\): ($msg)"
  git commit -m $commit_msg ...$rest
}