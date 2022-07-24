#!/bin/bash -e

# Arguments
USER_RC_PATH=${1:-"${HOME}"}
SKIP_FONTS=${2:-"true"}

# Variables
PATH_TO_PACK="${USER_RC_PATH}/.vim/pack"

if [ -x "$(command -v git)" ] && [ ! -d "${USER_RC_PATH}/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm "${USER_RC_PATH}/.tmux/plugins/tpm"
fi

if [ "${SKIP_FONTS}" != "true" ]; then
	font_dir="${USER_RC_PATH}/.local/share/fonts/"
	if [ ! -f "${font_dir}Hack Regular Nerd Font Complete.ttf" ]; then
		mkdir -p $font_dir
		curl -fLo ${USER_RC_PATH}/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
		unzip -d ${font_dir} ${USER_RC_PATH}/Hack.zip
		rm  ${USER_RC_PATH}/Hack.zip

		# Reset font cache on Linux
		if [[ -n $(command -v fc-cache) ]]; then
		  fc-cache -f "$font_dir"
		fi
	fi
fi


# list of files/folders to symlink in homedir
declare -a files
files=(.bashrc)
files+=(.inputrc)
files+=(.tmux.conf)
files+=(.vimrc)
files+=(.config/alacritty/alacritty.yml)
files+=(.config/starship.toml)

# dotfiles directory
cd "${PATH_TO_PACK}"
for file in "${files[@]}"; do
	SOURCE="${PATH_TO_PACK}/templates/${file}"
	DEST="${USER_RC_PATH}/${file}"
	DESTPATH="$(dirname ${DEST})"
	mkdir -p "${DESTPATH}" 2>/dev/null

	echo "creating symlink from ${SOURCE} to ${DEST}"
	ln -sf "${SOURCE}" "${DEST}"
done
