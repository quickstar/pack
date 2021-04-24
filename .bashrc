# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# With these bindings, up/down arrows will work like default if the command line is blank.
# If you have entered some text though, it will search the history for commands that start
# with the currently entered text.
if [[ $- == *i* ]]
then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind 'TAB:menu-complete'
fi

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
	git_message=" ${BLUE}git:(${RED}$(git branch 2>/dev/null | grep "^*" | colrm 1 2)${BLUE})"
	if [[ `git status --porcelain` ]]; then
	  git_message="${git_message}${YELLOW}✗"
	fi
  fi

  PS1="${PSTITLE}"
  PS1+="${status_color}➜  ${CYAN}\W"
  PS1+="${git_message}"
  PS1+=" ${RESET}"
  history -a
}

export PROMPT_COMMAND=prompt_command

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

unset color_prompt force_color_prompt
# some more ls aliases
alias l='ls -al'
alias ll='ls -CF'
alias la='ls -A'
alias ..='cd ..'
alias ~='cd ~/'

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
