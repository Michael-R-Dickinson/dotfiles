# Herdr support for temporary_install.sh.

temporary_herdr_initialize() {
    HERDR_CONFIG_PATH="$DOTFILES_TMP/.config/herdr/config.toml"
    export HERDR_CONFIG_PATH

    # Defined here, not in temporary_herdr_install, for two reasons:
    #   - the rcfile-generation loop in temporary_install.sh runs *before* the
    #     install step, so it can only bake this onto PATH if it is set by
    #     initialize time
    #   - re-runs skip the install step entirely, so a definition living in
    #     temporary_herdr_install would leave PATH without the temp herdr on
    #     every run after the first
    # Without this on PATH, a bare `herdr` resolves to whatever herdr is on the
    # real PATH, attaching to that install's server (and its unpatched config)
    # instead of this temp one.
    #
    # Named *_install_dir rather than reusing DOTFILES_TMP because the installer
    # drops a binary called `herdr` here, which would collide with the `herdr`
    # directory herdr itself creates under DOTFILES_TMP.
    HERDR_INSTALL_DIR="$DOTFILES_TMP/herdr_install_dir"
    export HERDR_INSTALL_DIR
}

temporary_herdr_install() {
    # $SHELL is frequently unset or stale (Docker/CI, minimal Ubuntu images,
    # non-login sessions) even when the script is actively running under bash,
    # so it alone is not a reliable signal here. $BASH_VERSION is only ever
    # set by the interpreter actually executing this code, so check that
    # first, matching the $BASH_VERSION/$ZSH_VERSION detection used at the
    # end of temporary_install.sh. $SHELL is kept as a fallback for the case
    # where this script itself isn't running under bash (e.g. invoked via
    # `sh`) but the target interactive shell still is.
    is_bash=
    [ -n "$BASH_VERSION" ] && is_bash=1
    case "$SHELL" in
        *bash*) is_bash=1 ;;
    esac

    if [ -n "$is_bash" ]; then
        # Herdr accepts an executable but no arguments for default_shell.
        # Use a wrapper so interactive bash panes load the temporary rcfile.
        herdr_bash_wrapper="$DOTFILES_TMP/temporary_herdr_bash.sh"
        chmod +x "$herdr_bash_wrapper"
        HERDR_BASH_WRAPPER="$herdr_bash_wrapper" perl -0pi -e '
            $path = $ENV{HERDR_BASH_WRAPPER};
            $path =~ s/\\/\\\\/g;
            $path =~ s/"/\\"/g;
            s{\[terminal\]\n}{"[terminal]\ndefault_shell = \"$path\"\nshell_mode = \"non_login\"\n"}e;
        ' "$HERDR_CONFIG_PATH"
    fi

    # HERDR_INSTALL_DIR is exported by temporary_herdr_initialize so the piped
    # installer below sees it.
    mkdir -p "$HERDR_INSTALL_DIR"
    curl -fsSL https://herdr.dev/install.sh | sh
    export PATH="$HERDR_INSTALL_DIR:$PATH"
}
