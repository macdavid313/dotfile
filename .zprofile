### to make Emacs Tramp worker properly when using zsh
### see https://www.emacswiki.org/emacs/TrampMode#h5o-9
if [ $TERM = tramp ]; then
        unset RPROMPT
        unset RPS1
        PS1="$ "
        unsetopt zle
        unsetopt rcs  # Inhibit loading of further config files
fi
