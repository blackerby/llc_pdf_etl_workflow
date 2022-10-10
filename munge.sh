#!/usr/bin/env zsh

# remove backup directory
PWD=$(pwd)
rm -rf "${PWD}.bak"

# create new backup directory
cp -R $PWD "${PWD}.bak"
