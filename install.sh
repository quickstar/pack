#!/bin/bash -e

MYHOME=${1:-"${HOME}"}

# dotfiles directory
PATH_TO_PACK="${MYHOME}/.vim/pack"

if [ -x "$(command -v git)" ] && [ ! -d "${MYHOME}/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm "${MYHOME}/.tmux/plugins/tpm"
fi

font_dir="${MYHOME}/.local/share/fonts/"
if [ ! -f "${font_dir}Hack Regular Nerd Font Complete.ttf" ]; then
	mkdir -p $font_dir
	curl -fLo ${MYHOME}/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
	unzip -d ${font_dir} ${MYHOME}/Hack.zip
	rm  ${MYHOME}/Hack.zip

	# Reset font cache on Linux
	if [[ -n $(command -v fc-cache) ]]; then
	  fc-cache -f "$font_dir"
	  case $? in
		[0-1])
		  # Catch fc-cache returning 1 on a success
		  exit 0
		  ;;
		*)
		  exit $?
		  ;;
	  esac
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

cd "${PATH_TO_PACK}"

for file in "${files[@]}"; do
	SOURCE="${PATH_TO_PACK}/templates/${file}"
	DEST="${MYHOME}/${file}"
	DESTPATH="$(dirname ${DEST})"
	mkdir -p "${DESTPATH}" 2>/dev/null

	echo "creating symlink from ${SOURCE} to ${DEST}"
	ln -sf "${SOURCE}" "${DEST}"
done

