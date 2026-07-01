Temporary Install

Installs everything into a single throwaway temp dir (`${TMPDIR:-/tmp}/dotfiles-tmp`)
and drops you straight into a configured tmux. Nothing outside the temp dir is
touched, and re-running detects the existing install instead of redoing it.
Works on Linux and macOS, with zsh or bash.

```
source <(curl -sL https://raw.githubusercontent.com/Michael-R-Dickinson/dotfiles/refs/heads/main/temporary_install.sh)
```

Inside tmux, install the tmux plugins with `prefix + I` (prefix is `C-a`).

Set `DOTFILES_NO_TMUX=1` to skip the auto-launch (just set up the shell), or
`DOTFILES_SRC=/path/to/repo` to install from a local checkout instead of GitHub.

Permanant Install
```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
