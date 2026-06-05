# Temp dotfile dir
DOTFILES_TMP=$(mktemp -d)
git -C "$DOTFILES_TMP" clone https://github.com/Michael-R-Dickinson/dotfiles.git .
# DOTFILES_TMP=.

# Rename files in the form "dot_zshrc" to ".zshrc"
(cd "$DOTFILES_TMP" &&
    for file in $(ls | grep -E "dot_*"); do
        mv "$file" ".${file#dot_}"
    done
)

# Set shell and dotfiles paths
TMUX_CONF="$DOTFILES_TMP/tmux/tmux.conf"
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"
export TMUX_TMP_SOCKET="dotfiles-$(basename "$DOTFILES_TMP")"
export TMUX_CONF

# Put tmux config where TPM looks for it when XDG_CONFIG_HOME is overridden.
mkdir -p "$DOTFILES_TMP/tmux"
mv "$DOTFILES_TMP/.tmux.conf" "$TMUX_CONF"

# Make temporary rc files self-locating for shells started later, including tmux panes.
for rcfile in "$DOTFILES_TMP/.zshrc" "$DOTFILES_TMP/.bashrc"; do
    if [ -f "$rcfile" ]; then
        tmp_rcfile="$rcfile.tmp"
        {
            printf 'export DOTFILES_TMP="%s"\n' "$DOTFILES_TMP"
            printf 'export XDG_CONFIG_HOME="%s"\n' "$DOTFILES_TMP"
            printf 'export TMUX_TMP_SOCKET="%s"\n' "$TMUX_TMP_SOCKET"
            printf 'export TMUX_CONF="%s"\n' "$TMUX_CONF"
            cat "$rcfile"
        } > "$tmp_rcfile" && mv "$tmp_rcfile" "$rcfile"
    fi
done

# Alias tools to use config files
alias tmux='tmux -L "$TMUX_TMP_SOCKET" -f "$TMUX_CONF"'

# Tmux setup - force dotfile bashrc
if [[ $SHELL == "/bin/bash" ]]; then
    echo "set -g default-command \"bash --rcfile $DOTFILES_TMP/.bashrc\"" >> "$TMUX_CONF"
fi

# TPM
git clone https://github.com/tmux-plugins/tpm "$DOTFILES_TMP/plugins/tpm"
perl -0pi -e "s|run '~/.tmux/plugins/tpm/tpm'|run '$DOTFILES_TMP/plugins/tpm/tpm'|" "$TMUX_CONF"
perl -0pi -e "s|source-file ~/.tmux.conf|source-file $TMUX_CONF|" "$TMUX_CONF"
{
    printf "set-environment -g TMUX_PLUGIN_MANAGER_PATH '%s/plugins/'\n" "$DOTFILES_TMP"
    printf "set-environment -g XDG_CONFIG_HOME '%s'\n" "$DOTFILES_TMP"
    cat "$TMUX_CONF"
} > "$TMUX_CONF.tmp" && mv "$TMUX_CONF.tmp" "$TMUX_CONF"

# Starship
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$DOTFILES_TMP" --yes > /dev/null
export PATH="$DOTFILES_TMP:$PATH"

# Shell Specifics
if [[ $SHELL == "/bin/bash" ]]; then
    if [ -e ~/.bashrc.local ]; then
        source ~/.bashrc.local
        source ~/.bashrc
    fi
    source "$DOTFILES_TMP/.bashrc"
elif [[ $SHELL == "/bin/zsh" ]]; then
    if [ -e ~/.zshrc.local ]; then
        source ~/.zshrc.local
        source ~/.zshrc
    fi
    source "$DOTFILES_TMP/.zshrc"
fi
