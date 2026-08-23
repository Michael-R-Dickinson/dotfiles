# Herdr support for temporary_install.sh.

temporary_herdr_initialize() {
    HERDR_CONFIG_PATH="$DOTFILES_TMP/.config/herdr/config.toml"
    export HERDR_CONFIG_PATH
}

temporary_herdr_install() {
    case "$SHELL" in
        *bash*)
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
            ;;
    esac

    # HERDR_INSTALL_DIR must be exported for the piped installer to see it.
    # Installing herdr creates a binary called herdr in the HERDR_INSTALL_DIR. If we make HERDR_INSTALL_DIR=DOTFILES_TMP then the herdr binary file name conflicts with
    # the herdr directory that is automatically created in DOTFILES_TMP - unclear why
    export HERDR_INSTALL_DIR="$DOTFILES_TMP/herdr_install_dir"; mkdir $HERDR_INSTALL_DIR; curl -fsSL https://herdr.dev/install.sh | sh
    export PATH="$HERDR_INSTALL_DIR:$PATH"
}
