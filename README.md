# dotfiles

## Included
- zsh
- i3
- doom emacs
- vscode

## Installation

```sh
wget -O initial-bootstrap.sh https://raw.githubusercontent.com/alaq/dotfiles/master/bootstrap.sh && initial-bootstrap.sh && rm initial-bootstrap.sh
```

The step above might fail. This is because your $HOME folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care, then re-run `config checkout`.

## Updating

``` sh
./bootstrap.sh
```
