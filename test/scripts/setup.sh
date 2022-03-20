#!/bin/bash
cd /home/ubuntu/data

# Use sed to replace the SSH URL with the public URL, then initialize submodules
sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules
git submodule update --init
sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules
git submodule update --init

./setup