#!/bin/bash

git_config() {
    return 0
}

neovim_config() {
    return 0
}

tmux_config() {
    mkdir -p "$HOME"/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins
    return $?
}
