#!/bin/sh
# chezmoi run_once (after files are applied): install the Pure zsh prompt via
# npm, without requiring elevated permissions. The --prefix matches the PURE_DIR
# the shipped .zshrc looks in ($HOME/.local/lib/node_modules/pure-prompt).
#
# npm is only needed here, at install time: the package itself is plain zsh. If
# npm is missing we skip silently-ish and the .zshrc falls back to Starship,
# which run_once_after_install-starship.sh installs alongside this.
set -e

PURE_DIR="$HOME/.local/lib/node_modules/pure-prompt"
[ -d "$PURE_DIR" ] && exit 0

if ! command -v npm >/dev/null 2>&1; then
    printf 'dotfiles: npm not found, zsh will use Starship instead of Pure\n' >&2
    exit 0
fi

npm install --global --prefix "$HOME/.local" pure-prompt
