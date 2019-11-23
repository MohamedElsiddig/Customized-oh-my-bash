#!/bin/bash
cite about-completion
about-completion 'Bash Completion for bd blugin'
# Add autocomplete support for bd for bash.
_bd()
{
   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi
    # Handle spaces in filenames by setting the delimeter to be a newline.
    local IFS=$'\n'
    # Current argument on the command line.
    local cur=${COMP_WORDS[COMP_CWORD]}
    # Available directories to autcomplete to.
    local completions=$( dirname `pwd` | sed 's|/|\'$'\n|g' )

    COMPREPLY=( $(compgen -W "$completions" -- $cur) )
}
if [[ `declare -F bd` ]]
	then
 		complete -F _bd bd
 	else
 		echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} bd completion requires bd plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion bd
fi
