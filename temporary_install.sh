# Temporary, throwaway dotfiles install.
#
# Everything lives under a single, consistent temp dir so that:
#   - nothing outside the temp dir is touched (fully reversible: rm -rf the dir)
#   - re-running is cheap: an existing install is detected and reused
#
# Usage (from the README):
#   source <(curl -sL https://raw.githubusercontent.com/.../temporary_install.sh)
#
# Testing against a local checkout instead of GitHub:
#   DOTFILES_SRC=/path/to/repo source ./temporary_install.sh
#
# Env knobs:
#   DOTFILES_TMP     override the temp dir (default: ${TMPDIR:-/tmp}/dotfiles-tmp)
#   DOTFILES_SRC     copy from this local dir instead of cloning from GitHub
#   DOTFILES_NO_TMUX if set, do not auto-launch tmux at the end

# Consistent temp dir so repeat runs can detect an existing install.
DOTFILES_TMP="${DOTFILES_TMP:-${TMPDIR:-/tmp}/dotfiles-tmp}"
DOTFILES_TMP="${DOTFILES_TMP%/}"
MARKER="$DOTFILES_TMP/.dotfiles_installed"

# Paths/vars needed by both fresh installs and re-runs.
TMUX_CONF="$DOTFILES_TMP/tmux/tmux.conf"
export DOTFILES_TMP
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"
export TMUX_TMP_SOCKET="dotfiles"
export TMUX_CONF

if [ ! -f "$MARKER" ]; then
    # Fresh install: start from a clean dir.
    rm -rf "$DOTFILES_TMP"
    mkdir -p "$DOTFILES_TMP"

    # Populate the temp dir: local source for testing, otherwise clone.
    if [ -n "$DOTFILES_SRC" ]; then
        cp -R "$DOTFILES_SRC"/. "$DOTFILES_TMP"/
        rm -rf "$DOTFILES_TMP/.git"
    else
        git clone --depth 1 https://github.com/Michael-R-Dickinson/dotfiles.git "$DOTFILES_TMP"
    fi

    # Rename files in the form "dot_zshrc" to ".zshrc".
    for file in "$DOTFILES_TMP"/dot_*; do
        [ -e "$file" ] || continue
        base=$(basename "$file")
        mv "$file" "$DOTFILES_TMP/.${base#dot_}"
    done

    # Put tmux config where TPM looks for it when XDG_CONFIG_HOME is overridden.
    mkdir -p "$DOTFILES_TMP/tmux"
    mv "$DOTFILES_TMP/.tmux.conf" "$TMUX_CONF"

    # Make temporary rc files self-locating for shells started later (tmux panes).
    for rcfile in "$DOTFILES_TMP/.zshrc" "$DOTFILES_TMP/.bashrc"; do
        [ -f "$rcfile" ] || continue
        tmp_rcfile="$rcfile.tmp"
        {
            printf 'export DOTFILES_TMP="%s"\n' "$DOTFILES_TMP"
            printf 'export XDG_CONFIG_HOME="%s"\n' "$DOTFILES_TMP"
            printf 'export ZDOTDIR="%s"\n' "$DOTFILES_TMP"
            printf 'export TMUX_TMP_SOCKET="%s"\n' "$TMUX_TMP_SOCKET"
            printf 'export TMUX_CONF="%s"\n' "$TMUX_CONF"
            printf 'export PATH="%s:$PATH"\n' "$DOTFILES_TMP"
            cat "$rcfile"
        } > "$tmp_rcfile" && mv "$tmp_rcfile" "$rcfile"
    done

    # TPM: clone it and point the tmux config at the temp paths.
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$DOTFILES_TMP/plugins/tpm"
    perl -0pi -e "s|run '~/.tmux/plugins/tpm/tpm'|run '$DOTFILES_TMP/plugins/tpm/tpm'|" "$TMUX_CONF"
    perl -0pi -e "s|source-file ~/.tmux.conf|source-file $TMUX_CONF|g" "$TMUX_CONF"
    {
        # TPM installs plugins here (prefix + I) and reads config from here.
        printf "set-environment -g TMUX_PLUGIN_MANAGER_PATH '%s/plugins/'\n" "$DOTFILES_TMP"
        printf "set-environment -g XDG_CONFIG_HOME '%s'\n" "$DOTFILES_TMP"
        # New zsh panes read \$ZDOTDIR/.zshrc; new bash panes handled below.
        printf "set-environment -g ZDOTDIR '%s'\n" "$DOTFILES_TMP"
        cat "$TMUX_CONF"
    } > "$TMUX_CONF.tmp" && mv "$TMUX_CONF.tmp" "$TMUX_CONF"

    # bash has no ZDOTDIR equivalent, so force our rc for bash panes.
    case "$SHELL" in
        *bash*) printf 'set -g default-command "bash --rcfile %s/.bashrc"\n' "$DOTFILES_TMP" >> "$TMUX_CONF" ;;
    esac

    # Starship prompt, installed into the temp dir only.
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$DOTFILES_TMP" --yes > /dev/null

    touch "$MARKER"
fi

# Always set up the current shell (whether fresh install or reuse).
export PATH="$DOTFILES_TMP:$PATH"

# Alias tmux to use the temp socket + config.
alias tmux='tmux -L "$TMUX_TMP_SOCKET" -f "$TMUX_CONF"'

# Source local overrides (if any) then our rc into the current shell.
if [ -n "$ZSH_VERSION" ]; then
    [ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
    . "$DOTFILES_TMP/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    [ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
    . "$DOTFILES_TMP/.bashrc"
fi

# Drop straight into the configured tmux (skip if already inside one, or opted out).
# `command` bypasses the alias; new-session -A attaches to an existing session.
if [ -z "$TMUX" ] && [ -z "$DOTFILES_NO_TMUX" ]; then
    command tmux -L "$TMUX_TMP_SOCKET" -f "$TMUX_CONF" new-session -A -s dotfiles
fi
