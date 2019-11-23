#!/usr/bin/env bash
# Bash completion support for the 'dirs' plugin (commands G, R).
cite about-completion
about-completion 'Bash completion support for the "dirs" plugin (commands G, R)'

_dirs-complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # parse all defined shortcuts from ~/.dirs
    if [ -r "$HOME/.dirs" ]; then
        COMPREPLY=($(compgen -W "$(grep -v '^#' ~/.dirs | sed -e 's/\(.*\)=.*/\1/')" -- ${CURRENT_PROMPT}) )
    fi

    return 0
}
if [[ `declare -F  dirs-help` ]]
	then
		complete -o default -o nospace -F _dirs-complete G R
	else
		echo ""
		sleep 1
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} dirs completion requires dirs plugin.. Please make sure it's enabled${echo_normal}" 
			echo ""
			sleep 1
			echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
			${echo_normal}"
			sleep 1
			_disable-completion dirs
fi
