#!/bin/bash
##################################
cite about-completion
about-completion 'Bash completion support for fastfile plugin commands'
    
  #Completin Function
_fastfile_completion()
	{
	 if [ "${#COMP_WORDS[@]}" != "2" ]; then
			return
		fi
		words=$(ls ~/.fastfile/)
		 COMPREPLY=($(compgen -W "${words}" "${COMP_WORDS[1]}"))
	 }
    
if [[ `declare -F fastfile` ]]
	then  
		complete -F _fastfile_completion fastfile_print fastfile_rm ffp ffrm
	else
		sleep 1
		echo ""
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} fastfile completion requires fastfile plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion fastfile 
fi
