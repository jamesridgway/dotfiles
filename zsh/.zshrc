# Path to your oh-my-zsh installation.

# Editor
export EDITOR="vim"

# Aliases
# List SSH hosts from SSH config
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" $HOME/.ssh/config | sed 's/Host //'"

# PATH
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin"

# Floow laptop
alias floow-pass="PASSWORD_STORE_DIR=$HOME/.floowpass pass"

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
