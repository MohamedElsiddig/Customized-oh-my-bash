cite about-plugin
about-plugin 'Search&Select history and fasd with percol'

# Notice
## You have to upgrade bash to bash 4.x on Mac OS X.
## http://stackoverflow.com/questions/16416195/how-do-i-upgrade-bash-in-mac-osx-mountain-lion-and-set-it-the-correct-path

# Install
## (sudo) pip install percol
## oh-my-bash enable percol
## optional: oh-my-bash enable fasd

# Usage
## C-r to search&select from history
## zz to search&select from fasd

_replace_by_history() {
    if command -v tac>/dev/null; then
        alias _tac=tac
    else
        alias _tac="tail -r"
    fi
    local l=$(HISTTIMEFORMAT= history | _tac | sed -e 's/^\ *[0-9]*\ *//' | percol --query "$READLINE_LINE")
    READLINE_LINE="$l"
    READLINE_POINT=${#l}
}


if command -v percol>/dev/null; then
    current_version=${BASH_VERSION%%[^0-9]*}
    if [ $current_version -lt 4 ]; then
       echo -e "\033[91mWarning: You have to upgrade Bash to Bash v4.x to use the 'percol' plugin.\033[m"
       echo -e "\033[91m         Your current Bash version is $BASH_VERSION.\033[m"
    else
        bind -x '"\C-r": _replace_by_history'

        # bind zz to percol if fasd enable
        if [[ $(type -t zz) == 'alias'  ]]; then
          unalias zz
        fi

        if command -v fasd>/dev/null; then
            function zz() {
                local l=$(fasd -d | awk '{print $2}' | percol)
                cd $l
            }
        fi
    fi
fi
