#!/bin/bash

RED='\033[0;31m'
RESET='\033[0m'

my_dir=$(cd "$(dirname "$0")" && pwd)

dir_name=$(basename "$my_dir")

if [ "$dir_name" != "dotfiles" ]; then
    echo -e "${RED}Error:${RESET} This script must be in dotfiles directory"
    echo "Current directory is: $dir_name"
    exit 1
fi

if [ "$(basename "$PWD")" != "dotfiles" ]; then
    cd "$my_dir"
fi


for file in .*; do
    if [ "$file" == "." ]; then
        continue
    elif [ "$file" == ".." ]; then
        continue
    elif [ "$file" == ".git" ]; then
        continue
    fi

    if [ -f "$file" ]; then
        ln -sfv "$PWD/$file" "$HOME/$file"
    elif [ -d "$file" ]; then
        if [ "$file" == ".config" ]; then
            for subfolder in "$file"/*; do
                if [ -d "$subfolder" ]; then
                    mkdir -p "$HOME/$subfolder"
                    ln -sfvn "$PWD/$subfolder" "$HOME/$subfolder"
                fi
            done
        else
            ln -sfvn "$PWD/$file" "$HOME/$file"
        fi
    fi
        

done
