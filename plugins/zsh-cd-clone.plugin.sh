#!/usr/bin/env bash
cite about-plugin
about-plugin 'A clone of Zsh `cd` builtin command'
# A clone of Zsh `cd` builtin command
function cd() {
  declare oldpwd="$OLDPWD"
  declare -i index
  if [[ "$#" -eq 1 && "$1" == -[1-9]* ]]; then
    index="${1#-}"
    if [[ "$index" -ge "${#DIRSTACK[@]}" ]]; then
      builtin echo "cd: no such entry in dir stack" >&2
      return 1
    fi
    set -- "${DIRSTACK[$index]}"
  fi
  builtin pushd . >/dev/null &&
    OLDPWD="$oldpwd" builtin cd "$@" &&
    oldpwd="$OLDPWD" &&
    builtin pushd . >/dev/null &&
    for ((index="${#DIRSTACK[@]}"-1; index>=1; index--)); do
      if [[ "${DIRSTACK[0]}" == "${DIRSTACK[$index]}" ]]; then
        builtin popd "+$index" >/dev/null || return 1
      fi
    done
  OLDPWD="$oldpwd"
}
