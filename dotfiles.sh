#!/bin/bash
set -e

function check_apt_installed() {
    return dpkg -l "$1" &> /dev/null
}
function apt_install() {
    if dpkg --get-selections | grep -q "^$1[[:space:]]*install$" >/dev/null; then
    	echo "$1 is already installed"
    else
    	echo "$1 is being installed. Sudo password may be needed"
        sudo apt-get -qq install -y "$1"
    fi
}
function is_sudo() {
    if groups | grep -q "\\bsudo\b"; then
        return 0
    fi
    return 1
}

INSTALL_PATH="$HOME/projects"

echo -e "This is a self-install script for James Ridgway's dotfiles.\n\n"


echo "git is required to clone the repository."
if command -v apt-get > /dev/null; then
    if is_sudo -eq 0; then
	    apt_install "git"   
	else
	    echo "ERROR: 'git' is not installed and you are not a sudoer. Please install git."
	fi
fi

mkdir -p "$INSTALL_PATH"
echo "Cloning the repository to: $INSTALL_PATH/dotfiles"

if [ -d "$INSTALL_PATH/dotfiles" ]; then
    echo "dotfiles already exists"
else
    git clone https://github.com/jamesridgway/dotfiles.git "$INSTALL_PATH/dotfiles"
fi


echo -e "\n\nThe dotfiles setup script will now be run...\n\n"
eval "$INSTALL_PATH/dotfiles"