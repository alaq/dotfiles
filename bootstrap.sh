#!/usr/bin/env bash
set -e

bold () {
    echo -e "\033[1m$1\033[0m"
}

# Add ppa
bold "Adding PPAs"
sudo add-apt-repository ppa:kelleyk/emacs -y

bold "Updating Ubuntu's packages"
sudo apt update
sudo apt upgrade -y
bold "Installing software"
sudo apt install git emacs26 curl fonts-firacode python3-pip neovim clojure leiningen ripgrep tree -y

curl -sLO https://raw.githubusercontent.com/borkdude/clj-kondo/master/script/install-clj-kondo
chmod +x install-clj-kondo
sudo ./install-clj-kondo

# emacs
# bold "Installing/updating doom-emacs"
# git clone https://github.com/hlissner/doom-emacs -b develop ~/.emacs.d 2> /dev/null || git -C ~/.emacs.d pull
# cd
# ./.emacs.d/bin/doom sync

# vscode
bold "Installing vscode and extensions"
# sudo snap install --classic code
# now need to download this link https://go.microsoft.com/fwlink/?LinkID=760868 
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

