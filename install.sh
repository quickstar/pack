#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

# dotfiles directory
dir=${HOME}/.vim/pack

# list of files/folders to symlink in homedir
files=".bashrc .inputrc .tmux.conf .vimrc"

##########

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

for file in $files; do
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

