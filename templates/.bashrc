# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth:erasedups

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=$HISTSIZE
HISTIGNORE="history*:exit"

# append to the history file, don't overwrite it
# and check the window size after each command, if necessary,
# update the values of LINES and COLUMNS.
shopt -s histappend checkwinsize

function historymerge {
    history -n; history -w; history -c; history -r;
}
trap historymerge EXIT

STARSHIPBIN=/home/quickstar/git/starship/target/debug/starship

if ! [ -x "$(command -v $STARSHIPBIN)" ]; then
	GREEN="\[\e[1;32m\]"
	RED="\[\e[1;31m\]"
	YELLOW="\[\e[0;93m\]"
	BLUE="\[\e[0;94m\]"
	CYAN="\[\e[0;96m\]"
	RESET="\[\e[m\]"
	PSTITLE="${YELLOW}[\u@\h - $(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')]\n"


	# Customize prompt
	prompt_command() {
	  local err_code="$?"
	  local status_color=""
	  local git_message=""

	  if [ $err_code != 0 ]; then
		status_color=$RED
	  else
		status_color=$GREEN
	  fi

	  if [ $(git rev-parse --is-inside-work-tree 2>/dev/null) ]; then
		git_message=" ${BLUE}git:(${RED}$(git branch 2>/dev/null | grep "^*" | cut -c3-)${BLUE})"
		if [[ `git status --porcelain` ]]; then
		  git_message="${git_message}${YELLOW}✗"
		fi
	  fi

	  PS1="${PSTITLE}"
	  PS1+="${status_color}➜  ${CYAN}\W"
	  PS1+="${git_message}"
	  PS1+=" ${RESET}"
	  historymerge
	}

	export PROMPT_COMMAND=prompt_command
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

if [ -x "$(command -v kubectl)" ]; then
	alias k='kubectl'
	# Enable kubectl autocompletion
	source <(kubectl completion bash)
	# Enable autocompletion also for k alias
	complete -F __start_kubectl k
fi

if [ -x "$(command -v docker)" ]; then
	alias dka='if [[ $(docker ps -q) ]]; then docker kill $(docker ps -q); fi'
	alias dcp='docker container prune -f'
	alias dip='docker image prune -f'
	alias dvp='docker volume prune -f'
	alias drd='docker rmi -f $(docker images | grep devcontainer\|vsc)'
	alias dclean='dka && dcp && dip && dvp'
	alias rmif='docker rmi -f $(docker images -q)'
fi

if [ -x "$(command -v git)" ]; then
	alias gs='git status'
	alias s='git status'
	alias gh="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
fi

if [ -x "$(command -v batcat)" ]; then
	alias bat='batcat'
fi

alias ..='cd ..'
alias ~='cd ~/'
alias cgit='cd ~/git'
alias cplace='cd ~/git/placeme'
alias l='ls -alh'
alias ll='ls -lh'
alias la='ls -A'

# enable vi mode in bash
set -o vi

export GOPATH=$HOME/git
export PATH="~/bin:~/.local/bin:/usr/local/go/bin:$GOPATH/bin:$PATH"
export EDITOR=vim

if [ -x "$(command -v zoxide)" ]; then
	alias cd='z'
	eval "$(zoxide init bash)"
fi

if [ -x "$(command -v starship)" ]; then
	eval "$(starship init bash)"
fi

if [ -x "$(command -v hcloud)" ]; then
	source <(hcloud completion bash)
fi

if [ -x "$(command -v cargo)" ]; then
	. "$HOME/.cargo/env"
fi

