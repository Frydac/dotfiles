autoload -Uz edit-command-line
autoload -Uz add-zsh-hook

export EDITOR=nvim

##
# I keep my 'shared' zshrc config in here:
# This way I can use my config on other ppl's machines without too much hassle (i.e. not replace existing zshrc)

# use vim bindingings rather than emacs style bindings
bindkey -v

# not sure if this is needed, sometimes ctrl-r is not working?
bindkey '' history-incremental-search-backward

# make numpad * work, for more info see: https://superuser.com/questions/742171/zsh-z-shell-numpad-numlock-doesnt-work
bindkey -s "^[Oj" "*"

# make delete key work as expected in vim mode
# in insert mode
bindkey '^[[3~' delete-char
# also in normal mode
bindkey -a '^[[3~' delete-char

# edit command line in editor (vim)
# Enable edit-command-line widget
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# disable globbing for arguments of these commands
noglob_cmds=(
    rake
    git
    gdb
    gdbgui
    rr
)
for cmd in $noglob_cmds; do
    alias $cmd="noglob $cmd"
done

# source other files
files_to_source=(
   aliases
   functions
   options
   auro_compiler
   plugins_antidote
   dirs
   path
   # Add new files here
   # extra_config
)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"
for file in $files_to_source; do
   [[ -f "$SCRIPT_DIR/$file.zsh" ]] && source "$SCRIPT_DIR/$file.zsh"
done


##
# source/load external files
# load zoxide
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
fi
if command -v atuin > /dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

if command -v starship > /dev/null; then
    eval "$(starship init zsh)"
fi

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

