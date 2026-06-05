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
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"
export TMUX_TMP_SOCKET="dotfiles-$(basename "$DOTFILES_TMP")"

# Make temporary rc files self-locating for shells started later, including tmux panes.
for rcfile in "$DOTFILES_TMP/.zshrc" "$DOTFILES_TMP/.bashrc"; do
    if [ -f "$rcfile" ]; then
        tmp_rcfile="$rcfile.tmp"
        {
            printf 'export DOTFILES_TMP="%s"\n' "$DOTFILES_TMP"
            cat "$rcfile"
        } > "$tmp_rcfile" && mv "$tmp_rcfile" "$rcfile"
    fi
done

# Alias tools to use config files
alias vim='vim -u $DOTFILES_TMP/.vimrc'
alias tmux='tmux -L $TMUX_TMP_SOCKET -f $DOTFILES_TMP/.tmux.conf'

# Tmux setup - force dotfile bashrc
if [[ $SHELL == "/bin/bash" ]]; then
    echo "set -g default-command \"bash --rcfile $DOTFILES_TMP/.bashrc\"" >> "$DOTFILES_TMP/.tmux.conf"
fi

# TPM
git clone https://github.com/tmux-plugins/tpm "$DOTFILES_TMP/plugins/tpm"
perl -0pi -e "s|run '~/.tmux/plugins/tpm/tpm'|run '$DOTFILES_TMP/plugins/tpm/tpm'|" "$DOTFILES_TMP/.tmux.conf"
{
    printf "set-environment -g TMUX_PLUGIN_MANAGER_PATH '%s/plugins/'\n" "$DOTFILES_TMP"
    cat "$DOTFILES_TMP/.tmux.conf"
} > "$DOTFILES_TMP/.tmux.conf.tmp" && mv "$DOTFILES_TMP/.tmux.conf.tmp" "$DOTFILES_TMP/.tmux.conf"

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
