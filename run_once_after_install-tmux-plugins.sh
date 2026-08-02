#!/bin/sh
# chezmoi run_once (after files are applied): clone TPM and install the tmux
# plugins listed in ~/.tmux.conf, so a permanent install needs no manual
# `prefix + I`. Runs only under `chezmoi apply` -- the temporary install has
# its own TPM handling and never touches $HOME.
set -e

command -v tmux >/dev/null 2>&1 || {
    echo "tmux not found; skipping tmux plugin install." >&2
    exit 0
}

# All repositories installed by this hook are public. Avoid host credential
# helpers and prompts, which are unnecessary and can interfere with automation.
export GIT_TERMINAL_PROMPT=0
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=credential.helper
export GIT_CONFIG_VALUE_0=

TPM="$HOME/.tmux/plugins/tpm"
[ -d "$TPM" ] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"

# Use an isolated socket so an existing tmux server cannot supply stale paths
# or configuration to TPM.
TPM_TMUX_TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tpm.XXXXXX")
export TMUX_TMPDIR="$TPM_TMUX_TMPDIR"
trap 'rm -rf -- "$TPM_TMUX_TMPDIR"' EXIT HUP INT TERM

# TPM reads the @plugin list from a server that has sourced the config, so
# spin up a detached session, install, then tear it down.
tmux new-session -d -s tpm_install 2>/dev/null || true
"$TPM/bin/install_plugins"
tmux kill-session -t tpm_install 2>/dev/null || true
