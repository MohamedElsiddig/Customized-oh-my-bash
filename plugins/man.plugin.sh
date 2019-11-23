cite about-plugin
about-plugin 'This plugin adds a shortcut to insert man before the previous command when pressing alt + m'
man_command() {
	if [[ -n $READLINE_LINE ]];then
		if [[ $READLINE_LINE == man\ * ]]; then 
           READLINE_LINE="${READLINE_LINE#man }" 
        else
           READLINE_LINE="man $READLINE_LINE" 
        fi
	fi
}

man_command
bind -x '"\C-[m": "man_command"'

