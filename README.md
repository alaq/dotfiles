# dotfiles

## Included
- zsh
- i3
- doom emacs
- vscode

## Installation

```sh
git clone --bare https://github.com/alaq/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
config checkout
```

The step above might fail. This is because your $HOME folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care, then re-run `config checkout`.
