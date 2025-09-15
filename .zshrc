export LSCOLORS="Fxfxcxdxbxegedabagacad" 

alias vim='nvim'
alias ls='ls -GH'

bindkey -v

export NODE_COMPILE_CACHE=~/.cache/nodejs-compile-cache
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

autoload -U colors && colors

parse_git_branch() {
  local branch=""
  branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  local git_status=$(git status --porcelain 2>/dev/null)
  if echo "$git_status" | grep -q "^ M"; then
    branch="${branch}*"
  fi
  if echo "$git_status" | grep -qE "^ A|^\?\?"; then
    branch="${branch}+"
  fi
  if echo "$git_status" | grep -q "^ D"; then
    branch="${branch}-"
  fi

  if [[ -n "$branch" ]]; then
    branch="[${branch}]"
  fi
  echo "$branch"
}
update_prompt() {
    PROMPT="[%{$fg_bold[green]%}%n@%{$fg_bold[blue]%}%m]:%{$fg_bold[yellow]%}%~%{$fg_bold[red]%}$(parse_git_branch)$%{$reset_color%} "
}
precmd_functions+=(update_prompt)
update_prompt

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. ~/.bash_git

export PATH=$PATH:/Users/justinkim/.spicetify
