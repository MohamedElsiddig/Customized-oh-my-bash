cite about-plugin
about-plugin 'Sudo will be inserted before the command when pressing alt + s'
sudo_command() {
	if [[ -z $READLINE_LINE ]] 
	     then
	      READLINE_LINE="sudo $(sed -n '$p' $HISTFILE)"
	elif [[ $READLINE_LINE == sudo\ * ]]; then 
             READLINE_LINE="${READLINE_LINE#sudo }"
	elif [[ -n $READLINE_LINE ]];then  
            READLINE_LINE="sudo $READLINE_LINE"
	fi
}

sudo_command
bind -x '"\C-[s": "sudo_command"'

