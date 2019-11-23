#/usr/bin/env bash
cite about-completion
about-completion 'Bash completion for some of the functions found in base plugin'

_mkarchive_completions()
{ 
   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi

   COMPREPLY=($(compgen  -W "bz2 tgz tar zip 7z" "${COMP_WORDS[1]}")) 
   
}


if [[ `declare -F  mkarchive` ]]
	then
		complete  -o dirnames  -F _mkarchive_completions mkarchive
	else
		echo ""
		sleep 1
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} base completion requires base plugin.. Please make sure it's enabled${echo_normal}" 
			echo ""
			sleep 1
			echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
			${echo_normal}"
			sleep 1
			_disable-completion base
fi

