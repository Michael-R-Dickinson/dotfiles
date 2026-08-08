Temporary Install

Installs everything into a single throwaway temp dir (`${TMPDIR:-/tmp}/dotfiles-tmp`)
and drops you straight into a configured tmux. Nothing outside the temp dir is
touched, and re-running detects the existing install instead of redoing it.
Works on Linux and macOS, with zsh or bash.

```
source <(curl -sL https://raw.githubusercontent.com/Michael-R-Dickinson/dotfiles/refs/heads/main/temporary_install.sh)
```

To make the install (and your tmux sessions) survive a temp-dir cleanup, point
it at a persistent save dir with `DOTFILES_SAVE_DIR`. Both the install and the
tmux-resurrect state live under it, so re-running restores your sessions.

```
DOTFILES_SAVE_DIR=.dotfiles-save source <(curl -sL https://raw.githubusercontent.com/Michael-R-Dickinson/dotfiles/refs/heads/main/temporary_install.sh)
```

Inside tmux, install the tmux plugins with `prefix + I` (prefix is `C-a`).

Claude Code is isolated too: `CLAUDE_CONFIG_DIR` points at the temp dir, so
the repo's `claude/CLAUDE.md` and `claude/skills/` are used and nothing under
`~/.claude` is touched. This is a fresh config, so Claude will need a login.

Set `DOTFILES_NO_TMUX=1` to skip the auto-launch (just set up the shell), or
`DOTFILES_SRC=/path/to/repo` to install from a local checkout instead of GitHub.

Permanent Install
```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

The permanent install also installs Starship into `~/.local/bin` and installs
the configured tmux plugins.
