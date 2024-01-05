# Oh-my-zsh setup
export ZSH=$HOME/.oh-my-zsh
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  ZSH_THEME="jagnoster"
  plugins=(git autojump)
  source $ZSH/oh-my-zsh.sh
fi

# Editor
export EDITOR="vim"

# Aliases
# List SSH hosts from SSH config
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" $HOME/.ssh/config | sed 's/Host //'"
alias ec2-ls='aws ec2 describe-instances --query "Reservations[].Instances[].{Name: Tags[?Key=='"'"'Name'"'"'] | [0].Value, InstanceId: InstanceId, PrivateIpAddress: PrivateIpAddress, InstanceTyp: InstanceType, State: State.Name}"'
# PATH
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin"

# Android Sdk
if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
fi

# Go path
if [ -d "$HOME/projects/go-projects" ]; then
    export GOPATH="$HOME/projects/go-projects"
fi

if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# Python (macOS)
if [ -d "$HOME/Library/Python/3.7/bin" ]; then
    export PATH="$PATH:$HOME/Library/Python/3.7/bin"
fi


# Terraform caching
mkdir -p "${HOME}/.terraform.d/plugin-cache"
export TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /home/james/code/useful/phone-api/node_modules/tabtab/.completions/serverless.zsh ]] && . /home/james/code/useful/phone-api/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /home/james/code/useful/phone-api/node_modules/tabtab/.completions/sls.zsh ]] && . /home/james/code/useful/phone-api/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /home/james/code/useful/phone-api/node_modules/tabtab/.completions/slss.zsh ]] && . /home/james/code/useful/phone-api/node_modules/tabtab/.completions/slss.zsh

eval "$(zellij setup --generate-auto-start zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "$HOME/.rvm/scripts/rvm" ] && \. "$HOME/.rvm/scripts/rvm"
