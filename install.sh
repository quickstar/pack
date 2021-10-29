#!/bin/bash -e

MYHOME=${1:-"${HOME}"}

# dotfiles directory
PATH_TO_PACK="${MYHOME}/.vim/pack"

if [ -x "$(command -v git)" ]; then
	git clone https://github.com/tmux-plugins/tpm "${MYHOME}/.tmux/plugins/tpm"
fi

# list of files/folders to symlink in homedir
declare -a files
files=(.bashrc)
files+=(.inputrc)
files+=(.tmux.conf)
files+=(.vimrc)
files+=(.config/alacritty/alacritty.yml)

cd "${PATH_TO_PACK}"

for file in "${files[@]}"; do
	SOURCE="${PATH_TO_PACK}/templates/${file}"
	DEST="${MYHOME}/${file}"
	DESTPATH="$(dirname ${DEST})"
	mkdir -p "${DESTPATH}" 2>/dev/null

	echo "creating symlink from ${SOURCE} to ${DEST}"
	ln -sf "${SOURCE}" "${DEST}"
done

