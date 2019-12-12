#compdef offline
cite about-completion
about-completion 'offline plugin completion'

#typeset -A opt_args
#local context state line

#_arguments -s -S \
#    '-l | list[List all the offline commands]'\
#    '-r | remove[Clean the offline script]'\
#    '-x | execute[Execute all offline comands]'\
#    '-h | help[Show this help message]'\
#    && return 0

#    return 1



_offline() {
local cur prev
cur="${COMP_WORDS[COMP_CWORD]}"
prev="${COMP_WORDS[COMP_CWORD-1]}"
words=("-l list --list --ls -x execute --execute -r remove --remove --rm -h --help help") 

COMPREPLY=($(compgen -W "${words}" -- "${cur}"))

}

if [[ `declare -F offline` ]]
	then
 		complete -o default -F _offline offline
 	else
 		echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} offline completion requires offline plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion offline && cd $OLDPWD
fi
