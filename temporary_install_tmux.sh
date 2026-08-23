# tmux support for temporary_install.sh.

temporary_tmux_initialize() {
    TMUX_CONF="$DOTFILES_TMP/tmux/tmux.conf"
    TMUX_TMP_SOCKET="dotfiles"
    export TMUX_CONF TMUX_TMP_SOCKET
}

temporary_tmux_install() {
    # Put tmux config where TPM looks for it when XDG_CONFIG_HOME is overridden.
    mkdir -p "$DOTFILES_TMP/tmux"
    mv "$DOTFILES_TMP/.tmux.conf" "$TMUX_CONF"

    git clone --depth 1 https://github.com/tmux-plugins/tpm "$DOTFILES_TMP/plugins/tpm"
    perl -0pi -e "s|run '~/.tmux/plugins/tpm/tpm'|run '$DOTFILES_TMP/plugins/tpm/tpm'|" "$TMUX_CONF"
    perl -0pi -e "s|source-file ~/.tmux.conf|source-file $TMUX_CONF|g" "$TMUX_CONF"
    {
        # TPM installs plugins here (prefix + I) and reads config from here.
        printf "set-environment -g TMUX_PLUGIN_MANAGER_PATH '%s/plugins/'\n" "$DOTFILES_TMP"
        printf "set-environment -g XDG_CONFIG_HOME '%s'\n" "$DOTFILES_TMP"
        printf "set-environment -g CLAUDE_CONFIG_DIR '%s'\n" "$CLAUDE_CONFIG_DIR"
        # New zsh panes read $ZDOTDIR/.zshrc; new bash panes need an override.
        printf "set-environment -g ZDOTDIR '%s'\n" "$DOTFILES_TMP"
        command cat "$TMUX_CONF"
    } > "$TMUX_CONF.tmp" && mv "$TMUX_CONF.tmp" "$TMUX_CONF"

    case "$SHELL" in
        *bash*) printf 'set -g default-command "bash --rcfile %s/.bashrc"\n' "$DOTFILES_TMP" >> "$TMUX_CONF" ;;
    esac

    if [ -n "${RESURRECT_DIR:-}" ]; then
        mkdir -p "$RESURRECT_DIR"
        printf "set -g @resurrect-dir '%s'\n" "$RESURRECT_DIR" >> "$TMUX_CONF"
    fi
}

temporary_tmux_load() {
    alias tmux='tmux -L "$TMUX_TMP_SOCKET" -f "$TMUX_CONF"'

    if [ -z "$TMUX" ] && [ -z "${DOTFILES_NO_TMUX:-}" ]; then
        command tmux -L "$TMUX_TMP_SOCKET" -f "$TMUX_CONF" new-session -A -s dotfiles
    fi
}
