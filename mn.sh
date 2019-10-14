#!/usr/bin/env bash
set -e

NOW=`date`

rclone sync dropbox:org $HOME/.org-staging
[ ! -d "$HOME/.git-org" ] &&
    [ -f "$HOME/.org-staging/tasks.org" ] &&
    /usr/bin/git init --bare $HOME/.git-org &&
    /usr/bin/git --git-dir=$HOME/.git-org/ --work-tree=$HOME/.org-staging add .
/usr/bin/git --git-dir=$HOME/.git-org/ --work-tree=$HOME/.org-staging commit -am $NOW
[ ! -d "$HOME/org"] &&
    [ ! -d "$HOME/org/.git" ] &&
    /usr/bin/git clone $HOME/.git-org/ $HOME/org
git -C $HOME/org commit -am $NOW
git -C $HOME/org pull
git -C $HOME/org push
rclone sync $HOME/.org-staging dropbox:org
