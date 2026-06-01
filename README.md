Temporary Install
```
source <(curl -sL https://raw.githubusercontent.com/Michael-R-Dickinson/dotfiles/refs/heads/main/temporary_install.sh)
```

Permanant Install
```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
