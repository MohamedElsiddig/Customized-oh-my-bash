
# Because sometimes the "/usr/lib/command-not-found" doesn't work after applying some plugins
cite about-plugin
about-plugin 'Zsh like autocorrect plugin'

function_exists () {
    # Zsh returns 0 even on non existing functions with -F so use -f
    declare -f $1 > /dev/null
    return $?
}

if function_exists command_not_found_handle; then
    if ! function_exists orig_command_not_found_handle; then
        eval "orig_$(declare -f command_not_found_handle)"
    fi
else
    orig_command_not_found_handle () {
		# if [[ -x /usr/lib/command-not-found ]]	
		# 	then
		# 		/usr/lib/command-not-found -- $1
                return $? 
		# 	else
		# 		return 127
		# fi
    }
fi

command_not_found_handle () {
    orig_command_not_found_handle "$@"
    PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    eval $(thefuck $(fc -ln -1 | tail -n 1))

}
