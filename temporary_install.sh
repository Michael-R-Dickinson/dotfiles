# Source Originals
source ~/.zshrc

# Source our zshrc
source .zshrc

# Temp dotfile dir
# DOTFILES_TMP=$(mktemp -d)
# git -C $DOTFILES_TMP clone https://github.com/Michael-R-Dickinson/dotfiles.git .
DOTFILES_TMP=.

# Set shell and dotfiles paths
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"

# Alias tools to use config files
alias vim='vim -u $DOTFILES_TMP/.vimrc'
alias tmux='tmux -f $DOTFILES_TMP/.tmux.conf'

# Starship
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir $DOTFILES_TMP --yes
export PATH="$DOTFILES_TMP:$PATH"
