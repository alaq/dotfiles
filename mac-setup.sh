#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Trackpad: enable tap to click for this user and for the login screen
# doesn't seem to work, check https://github.com/mathiasbynens/dotfiles/issues/793
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Click -bool true
defaults write com.apple.AppleMultitouchTrackpad Click -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Install brew
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
/usr/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install)"; \
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/adrien/.zprofile; \
eval "$(/opt/homebrew/bin/brew shellenv)"; }

# Install mas
command /opt/homebrew/bin/mas >/dev/null 2>&1 || { /opt/homebrew/bin/brew install mas; }

# TODO install Brewfile
/opt/homebrew/bin/brew bundle

# TODO install LunarVim

# TODO install VS Code extensions

# Setup git
GIT_AUTHOR_NAME="Adrien Lacquemant"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="github@alaq.io"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

echo "All done! Some changes require a restart to take effect."
