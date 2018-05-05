#!/bin/bash
set -e

function check_apt_installed() {
    return dpkg -l "$1" &> /dev/null
}
function apt_install() {
    if dpkg --get-selections | grep -q "^$1[[:space:]]*install$" >/dev/null; then
    	echo "  $1 is already installed"
    else
    	echo "  $1 is being installed. Sudo password may be needed"
        sudo apt-get -qq install -y "$1"
    fi
}
function is_sudo() {
    if groups | grep -q "\\bsudo\b"; then
        return 0
    fi
    return 1
}

echo -e "This is a self-install script for James Ridgway's dotfiles.\n\n"
sleep 3

echo "git is required to clone the repository."
if command -v apt-get > /dev/null; then
    if is_sudo -eq 0; then
	    apt_install "git"   
	else
	    echo "ERROR: 'git' is not installed and you are not a sudoer. Please install git."
	fi
fi

mkdir -p "$HOME/projects"
echo "Cloning the repository to: $HOME/projects/dotfiles"
sleep 3

git clone git@github.com:jamesridgway/dotfiles.git "$HOME/projects/dotfiles"


echo "The dotfiles setup script will now be run..."


if is_sudo -eq 0; then
	sleep 3
	sudo "$HOME/projects/dotfiles/setup"
else
	echo "You are not a sudoer, the setup script will be run normally (some packages may not be installed)."
	eval "$HOME/projects/dotfiles"
fi