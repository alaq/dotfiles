#!/usr/bin/env bash

apt update && apt upgrade
apt install git curl -y

curl https://rclone.org/install.sh | sudo bash

curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
sudo apt-get install -y nodejs
