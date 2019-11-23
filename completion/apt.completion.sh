#!/bin/bash
cite about-completion
about-completion 'bash completion for apt-history function in apt plugin'
_apt_history_completions()
{
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi
    COMPREPLY=($(compgen -W "install upgrade remove rollback" "${COMP_WORDS[1]}"))
}

if [[ `declare -F apt-history` ]]
	then
 		complete -F _apt_history_completions apt-history
 	else
 		echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} apt completion requires apt plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion apt 
fi
