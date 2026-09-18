#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

for file in packages/*.nix; do
  package="${file##*/}"
  package="${package%.nix}"

  nix run github:Mic92/nix-update -- \
    --flake \
    --version-regex '^v([0-9]+\.[0-9]+\.[0-9]+)$' \
    "$package"
done
