cite about-completion
about-completion 'Bash completion for prm plugin'
_prm()
{
    local cur prev words cword opts commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    com="${COMP_WORDS[1]}"
    opts="-h --help -v --version"
    commands="active add copy edit list remove rename start stop"

    case $com in
        edit|remove)
            COMPREPLY=( $(compgen -W "$(prm list)" -- ${cur}) )
            return 0
            ;;
    esac

    case $prev in
        copy|rename|start)
            COMPREPLY=( $(compgen -W "$(prm list)" -- ${cur}) )
            return 0
            ;;
        *)
            case $com in
                active|add|copy|list|rename|start|stop)
                    COMPREPLY=()
                    return 0
                    ;;
                *)
                    COMPREPLY=( $(compgen -W "${commands} ${opts}" -- ${cur}) )
                    return 0
                    ;;
            esac
    esac

} 
if [[ `declare -F prm` ]]
	then
 		complete -F complete -F _prm prm
 	else
 		echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} prm completion requires prm plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion prm 
fi
