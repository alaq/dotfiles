#!/usr/bin/env bash
set -e

bold () {
    echo -e "\033[1m$1\033[0m"
}

# Add ppa
bold "Adding PPAs"
# sudo add-apt-repository ppa:kelleyk/emacs -y
# sudo add-apt-repository ppa:kgilmer/speed-ricer -y

bold "Updating Ubuntu's packages"
sudo apt update
sudo apt upgrade -y
bold "Installing software"
sudo apt install git zsh emacs26 rxvt-unicode i3-wm dmenu i3status rofi fonts-font-awesome arc-theme -y
# i3-gaps polybar

is_wsl=$(cat /proc/version | grep "microsoft" | wc -l)
if [ ! $is_wsl -eq 1 ]
then
    bold "Not using WSL, installing i3-gnome."
    sudo apt install gnome-flashback -y
    git clone https://github.com/i3-gnome/i3-gnome.git 2> /dev/null || git -C i3-gnome pull
    cd i3-gnome
   sudo make install
fi

bold "Changing default shell to zsh"
sudo chsh -s /bin/zsh # change shell to zsh

# emacs
bold "Installing/updating doom-emacs"
git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d 2> /dev/null || git -C ~/.emacs.d pull
cd
./.emacs.d/bin/doom refresh

# vscode
bold "Installing vscode and extensions"
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

bold "Getting dotfiles"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/alaq/dotfiles.git $HOME/.dotfiles 2> /dev/null || /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
