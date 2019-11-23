#!/usr/bin/env bash
##################################
#Completin Function for reference function
cite about-completion
about-completion 'Bash completion support for reference function found in .oh-my-bash/lib/composure.sh'

_reference_completion()
{
 if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi
   words=$(typeset -F)
    COMPREPLY=($(compgen -W "${words}" "${COMP_WORDS[1]}"))
    }
complete -F _reference_completion reference
