_note()
{
	local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--help --verbose --version"
	if [[ $COMP_CWORD == 1 ]]; then
    	COMPREPLY=( $(compgen -W "ls echo save edit run del install help" "$cur" ) )
    	return 0
    fi
	if [[ $COMP_CWORD == 2 ]]; then
        COMPREPLY=( $(compgen -W "$(ls ~/.notes)" -- ${cur}) )
        return 0
	fi
}
complete -F _note note
