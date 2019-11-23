cite about-plugin
about-plugin 'Copy the active line from the command line buffer into the system clipboard using alt + c'
copybuffer() {
	about 'Copy the active line from the command line buffer into the system clipboard using alt + c'
	group 'misc'
	if [[ `declare -F clipcopy`  ]]
		then
			if [[ -n $READLINE_LINE ]];then  
				printf %s "$READLINE_LINE" | clipcopy
			fi
		else
			sleep 1
			echo ""
			echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} Copybuffer plugin requires clipboard plugin.. Please make sure it's enabled${echo_normal}" 
			echo ""
			sleep 1
			echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
			${echo_normal}"
			sleep 1
			_disable-plugin copybuffer
	fi
}
copybuffer
bind -x '"\C-[c": "copybuffer"'

