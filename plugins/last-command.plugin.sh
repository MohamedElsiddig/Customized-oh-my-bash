cite about-plugin
about-plugin 'Rewrite last command when pressing alt + r'
repeat_command() {
	if [[ -z $READLINE_LINE ]] 
	     then
	      READLINE_LINE="$(sed -n '$p' $HOME/.bash_history)"
	elif [[ -n $READLINE_LINE ]];then  
            READLINE_LINE=""
	fi
}

repeat_command
bind -x '"\C-[r": "repeat_command"'

