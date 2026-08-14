#!/bin/bash
RED='\033[0;31m'
RESET='\033[0m'

my_dir=$(cd "$(dirname "$0")" && pwd)

dir_name=$(basename "$my_dir")

if [ "$dir_name" != ".dotfiles" ]; then
    echo -e "${RED}Error:${RESET} This script must be in dotfiles directory"
    echo "Current directory is: $dir_name"
    exit 1
fi

if [ "$(basename "$PWD")" != ".dotfiles" ]; then
    cd "$my_dir"
fi

if [[ "$(uname)" = "Darwin" ]]; then
    echo "MacOS detected!"
    install_package() {
        if [[ ! "$#" -lt 2 ]]; then
            echo "Too few arguments!"
            exit 1
        fi

        brew install --non-interactive "$1" &> /dev/null
        return $?
    }
elif [[ "$(uname)" = "Linux" ]]; then
    echo "Linux detected"
    install_package() {
        if [[ ! "$#" -lt 2 ]]; then
            echo "Too few arguments!"
            exit 1
        fi

        yes | sudo pacman -S "$1" &> /dev/null
        return $?
    }
else 
    echo "Unknown operating system!"
    exit 1
fi

. "config_programs.sh"
while IFS="" read -r p; do
    if ! command -v "$p" &> /dev/null; then
        echo "$p is missing"
        echo "Installing $p"
        install_package "$p"
        exit_code=$?
        if [[ "$exit_code" -eq 0 ]]; then
            echo "$p installed succesffuly"
            echo "configurating $p"
        else
            echo "error during $p installation. Exit code: $exit_code"
        fi
    else
        echo "$p already installed"
    fi
done < "program_list"

shopt -s nullglob
for path in files/.*; do
    name="$(basename "$path")"
    [[ "$name" = "." || "$name" = ".." ]] && continue

    if [[ -f "$path" ]]; then
        ln -sfv "$my_dir/$path" "$HOME/$name"
    elif [[ -d "$path" ]]; then
        if [[ "$name" = ".config" ]]; then
            for subf in "$path"/*/; do
                subfname=$(basename "$subf")
                [[ "$subfname" = "." || "$subfname" = ".." ]] && continue
                ln -sfvn "$my_dir/$path/$subfname" "$HOME/.config/$subfname"
            done
        fi
    else
        echo "Error unknown type: $file"
    fi
done
shopt -u nullglob


