#!/bin/bash

MYHOME=${1:-"${HOME}"}

# dotfiles directory
PATH_TO_PACK="${MYHOME}/.vim/pack"

# list of files/folders to symlink in homedir
declare -a files
files=(.bashrc)
files+=(.inputrc)
files+=(.tmux.conf)
files+=(.vimrc)

cd "${PATH_TO_PACK}"

for file in "${files[@]}"; do
    echo "creating symlink from ${PATH_TO_PACK}/${file} to ${MYHOME}/${file}"
    ln -sf "${PATH_TO_PACK}/${file}" "${MYHOME}/${file}"
done

