# Temp dotfile dir
DOTFILES_TMP=$(mktemp -d)
git -C $DOTFILES_TMP clone https://github.com/Michael-R-Dickinson/dotfiles.git .
# DOTFILES_TMP=.

# Rename files in the form "dot_zshrc" to ".zshrc"
(cd $DOTFILES_TMP &&
    for file in $(ls | grep -E "dot_*"); do
        mv "$file" ".${file#dot_}"
    done
)

# Source our zshrc
source $DOTFILES_TMP/.shellrc

# Set shell and dotfiles paths
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"

# Alias tools to use config files
alias vim='vim -u $DOTFILES_TMP/.vimrc'
alias tmux='tmux -f $DOTFILES_TMP/.tmux.conf'

# Tmux setup - force dotfile bashrc
if [[ $SHELL == "/bin/bash" ]]; then
    echo "set -g default-command \"bash --rcfile $DOTFILES_TMP/.shellrc\"" >> $DOTFILES_TMP/.tmux.conf
fi

# TPM
git clone https://github.com/tmux-plugins/tpm $DOTFILES_TMP/plugins/tpm
sed -i "s|run '~/.tmux/plugins/tpm/tpm'|run '$DOTFILES_TMP/plugins/tpm/tpm'|" $DOTFILES_TMP/.tmux.conf
sed -i "1i set-environment -g TMUX_PLUGIN_MANAGER_PATH '$DOTFILES_TMP/plugins/'" $DOTFILES_TMP/.tmux.conf

# Starship
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir $DOTFILES_TMP --yes > /dev/null
export PATH="$DOTFILES_TMP:$PATH"
