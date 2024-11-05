#!/usr/bin/env bash

antidote_install_dir="$HOME/.antidote"

# Bootstrap Antidote
# Check if Antidote is installed, and install if not
if [[ ! -d "$antidote_install_dir" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_install_dir"
fi

# Source antidote
# source "$HOME/.antidote/antidote.zsh"
# shellcheck source=/dev/null
source "$antidote_install_dir"/antidote.zsh

antidote load

###
# Not useing default load settings, but copy pasted code from site to customize
# antidote load
# TODO: adding functions to fpath and loading causes issues

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
# zsh_plugins=~/.zsh_plugins

# zsh_plugins_txt=$HOME/.emile_sh/plugins_list.txt

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
# [[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
# fpath=("$antidote_install_dir"/functions "$fpath")
# autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
# if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
#   antidote bundle <"$zsh_plugins_txt" >|${zsh_plugins}.zsh
# fi

# antidote load \
#     zsh-users/zsh-autosuggestions

# Source your static plugins file.
# source ${zsh_plugins}.zsh
