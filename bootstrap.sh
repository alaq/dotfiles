#!/usr/bin/env bash
set -e

# Add ppa
echo "Adding PPAs"
# sudo add-apt-repository ppa:kelleyk/emacs -y
# sudo add-apt-repository ppa:kgilmer/speed-ricer -y

echo "Updating Ubuntu's packages"
sudo apt update
sudo apt upgrade -y
echo "Installing software"
sudo apt install git zsh emacs26 rxvt-unicode i3-wm dmenu i3status fonts-font-awesome arc-dark -y
# i3-gaps polybar

is_wsl=$(cat /proc/version | grep "microsoft" | wc -l)
if [ ! $is_wsl -eq 1 ]
then
    echo "Not using WSL, installing i3-gnome."
    sudo apt install gnome-flashback -y
    git clone https://github.com/i3-gnome/i3-gnome.git 2> /dev/null || git -C i3-gnome pull
    cd i3-gnome
    sudo make install >/dev/null 2>&1
fi

echo "Changing default shell to zsh"
sudo chsh -s /bin/zsh # change shell to zsh

# emacs
echo "Installing/updating doom-emacs"
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d 2> /dev/null || git -C ~/.emacs.d pull
cd
./.emacs.d/bin/doom refresh

# vscode
echo "Installing vscode and extensions"
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

echo "Getting dotfiles"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/alaq/dotfiles.git $HOME/.dotfiles 2> /dev/null || config pull
config checkout
config config --local status.showUntrackedFiles no
