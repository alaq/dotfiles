#!/usr/bin/env bash

# Add ppa
sudo add-apt-repository ppa:kelleyk/emacs &&
sudo add-apt-repository ppa:kgilmer/speed-ricer

sudo apt update &&
sudo apt upgrade &&
sudo apt install zsh emacs26 firefox i3-gaps

chsh -s /bin/zsh && # change shell to zsh

# emacs
rm -r ~/.emacs.d &&
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d &&
cd ~/.emacs.d &&
make quickstart &&
cd ~ &&

# vscode
# TODO Add installation step for vscode
if command -v code >/dev/null; then
    # from `code --list-extensions`
    modules="
dbaeumer.vscode-eslint
eamodio.gitlens
esbenp.prettier-vscode
gaearon.subliminal
vscodevim.vim
"
    for module in $modules; do
        code --install-extension "$module" || true
    done
fi

git clone --bare https://github.com/alaq/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
config checkout
