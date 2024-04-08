alias ..='cd ..'
alias ~='cd ~/'
alias cg='cd git'
alias l='ls -alh'
alias ll='ls -lh'
alias la='ls -A'
if [ -x "$(command -v lsd)" ]; then
	alias ls='lsd --group-dirs first'
fi
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Specify the locale settings for the user's shell session.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Enable vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Autocompleting for zsh-autosuggestions
bindkey '^l' autosuggest-accept

# Change cursor shape for different vi modes.
function zle-keymap-select {
if [[ ${KEYMAP} == vicmd ]] ||
	[[ $1 = 'block' ]]; then
	echo -ne '\e[2 q'
elif [[ ${KEYMAP} == main ]] ||
	[[ ${KEYMAP} == viins ]] ||
	[[ ${KEYMAP} = '' ]] ||
	[[ $1 = 'beam' ]]; then
	echo -ne '\e[5 q'
fi
}
zle -N zle-keymap-select
zle-line-init() {
zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

if [ -x "$(command -v git)" ]; then
	alias gs='git status'
	alias s='git status'
	alias gh="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
fi

if [ -x "$(command -v bat)" ]; then
	export BAT_THEME="Dracula"
	alias cat='bat'
	# enabling get colorized help pages e.g. cp --help
	alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
	alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v fzf &> /dev/null; then
	gd() {
	  preview="git diff $@ --color=always --name-only --relative --diff-filter=d  -- {-1} | xargs bat -diff"
	  git diff $@ --name-only | fzf -m --ansi --preview-window=70% --preview $preview
	}
	gd2() {
		git diff --name-only --relative --diff-filter=d | xargs bat --diff
	}
fi

if command -v zoxide &> /dev/null; then
	alias cd='z'
	eval "$(zoxide init zsh)"
fi

if command -v starship &> /dev/null; then
	eval "$(starship init zsh)"
fi

BREWPATH=$(brew --prefix)

# Fish shell-like syntax highlighting for Zsh.
# https://github.com/zsh-users/zsh-syntax-highlighting
source $BREWPATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $BREWPATH/share/zsh-autosuggestions/zsh-autosuggestions.zsh
