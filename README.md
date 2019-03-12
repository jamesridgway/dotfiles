# dotfiles
[![Build Status](https://travis-ci.org/jamesridgway/dotfiles.svg?branch=master)](https://travis-ci.org/jamesridgway/dotfiles)

Your dotfiles are how you personalise your system. These are mine,

I grew tired of having to setup and customise my system to suit my needs everytime I re-installed or switched to a new machine.

This dotfiles repository aims to eliminate the need for any manual configuration. Keeping configurations in-sync between machines is now also effortless.

![Dotfiles setup script screenshhot](https://files.james-ridgway.co.uk/dotfiles.gif)

## Approach
There is a single `./setup` script which is run as the installation process. This script will apply any changes.

This is largely achieved by symlinking dotfiles in this repository to those in the home directory.

This repository has been broken down into a folder structure for each tool that I use.

## Installation
Run:

    curl -sSL https://jmsr.io/dotfiles.sh | bash

Or, if you have cloned the repository run `./setup`.

## Components
In most cases, each tool has it's own folder, which is true of:
* gradle
* terminator
* tmux
* vim
* zsh

There is also a `scripts` directory which is a submodule of my [scripts](https://github.com/jamesridgway/scripts) repository. Anything in the scripts submodule is added to my `PATH` variable by symlinking to `~/bin`.

## Testing
In an attempt to ensure that this dotfiles setup will always work on a brand new, clean machine. I use the docker image in this repository to apply this repository to a clean Ubuntu 16.04 container.

[![Build Status](https://travis-ci.org/jamesridgway/dotfiles.svg?branch=master)](https://travis-ci.org/jamesridgway/dotfiles)
