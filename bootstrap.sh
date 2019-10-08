#!/usr/bin/env bash

# Add ppa
sudo add-apt-repository ppa:kelleyk/emacs -y &&
sudo add-apt-repository ppa:kgilmer/speed-ricer -y &&

sudo apt update &&
sudo apt upgrade &&
sudo apt install git zsh emacs26 firefox i3-gaps polybar fonts-font-awesome -y &&

is_wsl=$(cat /proc/version | grep "microsoft" | wc -l)
if [ ! $is_wsl -eq 1 ]
then
    echo "Not using WSL, installing i3-gnome."
    git clone https://github.com/i3-gnome/i3-gnome.git &&
    cd i3-gnome &&
    sudo make install
fi

chsh -s /bin/zsh && # change shell to zsh

# emacs
rm -r ~/.emacs.d &&
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d &&
cd ~/.emacs.d &&
./.emacs.d/bin/doom refresh &&

# vscode
sudo snap install --classic code
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
