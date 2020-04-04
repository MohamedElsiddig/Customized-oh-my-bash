# use our `vimrc` for initialization

cite about-dotfile
about-dotfile 'use our `vimrc` for initialization'

# check precondition
command -v vim 1>/dev/null || return "${SKIPPED}"

# activate
export VIMINIT="source ${PWD}/dotfiles/vimrc"
