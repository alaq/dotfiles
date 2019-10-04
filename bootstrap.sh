#!/usr/bin/env bash

# emacs
sudo add-apt-repository ppa:kelleyk/emacs &&
    sudo apt-get update &&
    sudo apt install emacs26 &&
    rm -r ~/.emacs.d
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d &&
    cd ~/.emacs.d &&
    make quickstart &&
    cd

# vscode
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
