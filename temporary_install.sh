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
#   DOTFILES_SAVE_DIR persistent root for the install + tmux-resurrect state, so
#                    tmux sessions survive a temp-dir cleanup (default: unset)
#   DOTFILES_SRC     copy from this local dir instead of cloning from GitHub
#   DOTFILES_NO_TMUX if set, do not auto-launch tmux at the end
#   DOTFILES_HISTORY persist Claude history here so `claude --resume` survives a
#                    temp-dir cleanup (default: ~/.local/state/dotfiles-claude)

# Optional persistent "save dir": when set, both the install (DOTFILES_TMP) and
# tmux-resurrect state live under it, so tmux sessions survive a temp-dir wipe.
# Resolve to an absolute path: it gets baked into the tmux config, and TPM/tmux
# run from a different working directory, so a relative path would break them.
DOTFILES_SAVE_DIR="${DOTFILES_SAVE_DIR:-}"
case "$DOTFILES_SAVE_DIR" in
    "")    ;;                                                   # unset
    "~")   DOTFILES_SAVE_DIR="$HOME" ;;
    "~/"*) DOTFILES_SAVE_DIR="$HOME/${DOTFILES_SAVE_DIR#\~/}" ;;
    /*)    ;;                                                   # already absolute
    ./*)   DOTFILES_SAVE_DIR="$PWD/${DOTFILES_SAVE_DIR#./}" ;;  # relative -> cwd
    *)     DOTFILES_SAVE_DIR="$PWD/$DOTFILES_SAVE_DIR" ;;
esac
DOTFILES_SAVE_DIR="${DOTFILES_SAVE_DIR%/}"

# Consistent temp dir so repeat runs can detect an existing install. A save dir,
# if given, roots the install in a persistent location you control instead.
if [ -n "$DOTFILES_SAVE_DIR" ]; then
    DOTFILES_TMP="${DOTFILES_TMP:-$DOTFILES_SAVE_DIR/dotfiles-tmp}"
else
    DOTFILES_TMP="${DOTFILES_TMP:-${TMPDIR:-/tmp}/dotfiles-tmp}"
fi
DOTFILES_TMP="${DOTFILES_TMP%/}"
MARKER="$DOTFILES_TMP/.dotfiles_installed"
TMUX_HELPER="$DOTFILES_TMP/temporary_install_tmux.sh"
HERDR_HELPER="$DOTFILES_TMP/temporary_install_herdr.sh"

# tmux-resurrect save location. With a save dir it persists there; otherwise we
# leave it unset so resurrect keeps its default (~/.local/share/tmux/resurrect).
if [ -n "$DOTFILES_SAVE_DIR" ]; then
    RESURRECT_DIR="$DOTFILES_SAVE_DIR/tmux-resurrect"
fi

# Paths/vars needed by both fresh installs and re-runs.
export DOTFILES_TMP
export XDG_CONFIG_HOME="$DOTFILES_TMP"
export ZDOTDIR="$DOTFILES_TMP"
# Claude Code ignores XDG_CONFIG_HOME; CLAUDE_CONFIG_DIR fully isolates its
# config (CLAUDE.md, skills, auth, state) inside the temp dir. The repo ships
# dot_claude/, which the dot_* rename loop below turns into .claude here.
export CLAUDE_CONFIG_DIR="$DOTFILES_TMP/.claude"

FRESH_INSTALL=
if [ ! -f "$MARKER" ] || [ ! -f "$TMUX_HELPER" ] || [ ! -f "$HERDR_HELPER" ]; then
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

    FRESH_INSTALL=1
fi

# These helpers live in the cloned checkout so the remote one-line installer
# does not need to download multiple scripts before it knows DOTFILES_TMP.
. "$TMUX_HELPER"
. "$HERDR_HELPER"
temporary_tmux_initialize
temporary_herdr_initialize

if [ -n "${FRESH_INSTALL:-}" ]; then

    # Rename files in the form "dot_zshrc" to ".zshrc".
    for file in "$DOTFILES_TMP"/dot_*; do
        [ -e "$file" ] || continue
        base=$(basename "$file")
        mv "$file" "$DOTFILES_TMP/.${base#dot_}"
    done

    # Claude reads CLAUDE.md/skills from here; ensure it exists even if the
    # shipped dot_claude/ dir is absent.
    mkdir -p "$CLAUDE_CONFIG_DIR/skills"

    # Persist Claude conversation history outside the throwaway temp dir so
    # `claude --resume` still works after DOTFILES_TMP is cleaned up. Transcripts
    # are keyed by real working directory, so resume matches across reinstalls.
    # This is the one thing we deliberately keep outside DOTFILES_TMP; wipe it
    # with `rm -rf "$DOTFILES_HISTORY"` for a truly clean slate.
    DOTFILES_HISTORY="${DOTFILES_HISTORY:-$HOME/.local/state/dotfiles-claude}"
    mkdir -p "$DOTFILES_HISTORY/projects" "$DOTFILES_HISTORY/todos"
    ln -sfn "$DOTFILES_HISTORY/projects" "$CLAUDE_CONFIG_DIR/projects"
    ln -sfn "$DOTFILES_HISTORY/todos" "$CLAUDE_CONFIG_DIR/todos"

    # Make temporary rc files self-locating for shells started later.
    for rcfile in "$DOTFILES_TMP/.zshrc" "$DOTFILES_TMP/.bashrc"; do
        [ -f "$rcfile" ] || continue
        tmp_rcfile="$rcfile.tmp"
        {
            printf 'export DOTFILES_TMP="%s"\n' "$DOTFILES_TMP"
            printf 'export XDG_CONFIG_HOME="%s"\n' "$DOTFILES_TMP"
            printf 'export ZDOTDIR="%s"\n' "$DOTFILES_TMP"
            printf 'export CLAUDE_CONFIG_DIR="%s"\n' "$CLAUDE_CONFIG_DIR"
            printf 'export HERDR_CONFIG_PATH="%s"\n' "$HERDR_CONFIG_PATH"
            printf 'export HERDR_INSTALL_DIR="%s"\n' "$HERDR_INSTALL_DIR"
            printf 'export TMUX_TMP_SOCKET="%s"\n' "$TMUX_TMP_SOCKET"
            printf 'export TMUX_CONF="%s"\n' "$TMUX_CONF"
            # HERDR_INSTALL_DIR must be on PATH here too, so that a bare `herdr`
            # typed inside a temp shell (or a herdr pane) runs the temp herdr and
            # talks to the temp server, rather than any herdr already installed
            # on the real PATH.
            printf 'export PATH="%s:%s:$PATH"\n' "$DOTFILES_TMP" "$HERDR_INSTALL_DIR"
            # `command` bypasses any `cat` alias (e.g. cat='bat --color=always')
            # from the invoking shell's real profile, which would otherwise
            # bake ANSI escape codes into this generated rc file.
            command cat "$rcfile"
        } > "$tmp_rcfile" && mv "$tmp_rcfile" "$rcfile"
    done

    temporary_tmux_install

    # Starship prompt, installed into the temp dir only. zsh prefers Pure below;
    # Starship stays the bash prompt and the zsh fallback when npm is missing.
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$DOTFILES_TMP" --yes > /dev/null

    # Pure prompt for zsh, installed into the temp dir only. The prefix matches
    # the PURE_DIR the temporary .zshrc computes from DOTFILES_TMP. npm is only
    # needed here at install time; the package itself is plain zsh.
    if command -v npm > /dev/null 2>&1; then
        npm install --global --prefix "$DOTFILES_TMP/.local" pure-prompt > /dev/null 2>&1 ||
            printf 'dotfiles: pure-prompt install failed, zsh will use Starship\n' >&2
    else
        printf 'dotfiles: npm not found, zsh will use Starship instead of Pure\n' >&2
    fi

    temporary_herdr_install

    touch "$MARKER"
fi

# Always set up the current shell (whether fresh install or reuse). The herdr
# install dir is included on re-runs too, where temporary_herdr_install (which
# also prepends it) is skipped.
export PATH="$DOTFILES_TMP:$HERDR_INSTALL_DIR:$PATH"

# Source local overrides (if any) then our rc into the current shell.
if [ -n "$ZSH_VERSION" ]; then
    [ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
    . "$DOTFILES_TMP/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    [ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
    . "$DOTFILES_TMP/.bashrc"
fi
