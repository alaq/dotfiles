#!/usr/bin/env bash

# Add ppa
sudo add-apt-repository ppa:kelleyk/emacs -y >/dev/null 2>&1 &&
sudo add-apt-repository ppa:kgilmer/speed-ricer -y >/dev/null 2>&1 &&

sudo apt update >/dev/null 2>&1 &&
sudo apt upgrade -y >/dev/null 2>&1 &&
sudo apt install git zsh emacs26 firefox i3-gaps polybar fonts-font-awesome -y >/dev/null 2>&1 &&

is_wsl=$(cat /proc/version | grep "microsoft" | wc -l)
if [ ! $is_wsl -eq 1 ]
then
    echo "Not using WSL, installing i3-gnome."
    sudo apt install gnome-flashback -y >/dev/null 2>&1 &&
    git clone https://github.com/i3-gnome/i3-gnome.git || git -C i3-gnome pull >/dev/null 2>&1 &&
    cd i3-gnome >/dev/null 2>&1 &&
    sudo make install >/dev/null 2>&1
fi

sudo chsh -s /bin/zsh >/dev/null 2>&1 && # change shell to zsh

# emacs
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d || git -C ~/.emacs.d pull >/dev/null 2>&1 &&
./.emacs.d/bin/doom refresh >/dev/null 2>&1

# vscode
sudo snap install --classic code >/dev/null 2>&1
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

git clone --bare https://github.com/alaq/dotfiles.git $HOME/.dotfiles || git -C ~/.dotfiles pull >/dev/null 2>&1
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
