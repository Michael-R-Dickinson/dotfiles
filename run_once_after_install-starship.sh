#!/bin/sh
# chezmoi run_once (after files are applied): install Starship for permanent
# installs without requiring elevated permissions.
set -e

command -v starship >/dev/null 2>&1 && exit 0

mkdir -p "$HOME/.local/bin"
curl -sS https://starship.rs/install.sh |
    sh -s -- --bin-dir "$HOME/.local/bin" --yes
