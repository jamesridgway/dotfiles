# Path to your oh-my-zsh installation.

# Oh-my-zsh setup
export ZSH=$HOME/.oh-my-zsh
#ZSH_THEME="jagnoster"
plugins=(git autojump)
source $ZSH/oh-my-zsh.sh

# Aliases
alias us-update="git --git-dir=$HOME/dotfiles/useful-scripts/.git pull && $HOME/projects/dotfiles/setup"

# PATH
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin"

# Floow laptop - add gems to path
if [ -d "$HOME/.gem/ruby/2.1.0/bin" ]; then
    export PATH="$PATH:$HOME/.gem/ruby/2.1.0/bin"
fi

# Go path
if [ -d "$HOME/projects/go-projects" ]; then
    export GOPATH="$HOME/projects/go-projects"
fi

if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# drone.io
export DRONE_SERVER=http://drone-io
export DRONE_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoiamFtZXMiLCJ0eXBlIjoidXNlciJ9.eKdsnnJr6Ll1TWlQqpP8oN8tyfCnh1Bnq_LBii2L3Rw

# Powerline
export POWERLINE_PATH=$(python3 -c 'import os; import pkgutil; print(os.path.dirname(pkgutil.get_loader("powerline").get_filename()))' 2>/dev/null)
if [[ "$POWERLINE_PATH" != "" ]]; then
  source ${POWERLINE_PATH}/bindings/zsh/powerline.zsh
fi

# Tmux
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  # ssh session
else
  if [ "$TMUX" = "" ]; then
    TMUX_ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
    if [[ -z "$TMUX_ID" ]]
    then
      tmux -2
    else
      tmux -2 attach-session -t "$TMUX_ID"
    fi
  fi
fi
