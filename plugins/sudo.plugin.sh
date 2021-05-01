cite about-plugin
about-plugin 'Toggle sudo at the beginning of the current or the previous command by hitting the ESC key twice'

function sudo-command-line() {
  about "toggle sudo at the beginning of the current or the previous command by hitting the ESC key twice"
  group "sudo"

  [[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -l -n -1 | xargs)
  if [[ $READLINE_LINE == sudo\ * ]]; then
    READLINE_LINE="${READLINE_LINE#sudo }"
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
  READLINE_POINT=${#READLINE_LINE}
}

# Define shortcut keys: [Esc] [Esc]

# Readline library requires bash version 4 or later
if [ "${BASH_VERSINFO}" -ge 4 ]; then
  bind -x '"\e\e": sudo-command-line'
fi


#######################################################
###    My Old Code
#######################################################
#cite about-plugin
#about-plugin 'Sudo will be inserted before the command when pressing alt + s'
#sudo_command() {
#	if [[ -z $READLINE_LINE ]] 
#	     then
#	      READLINE_LINE="sudo $(sed -n '$p' $HISTFILE)"
#	elif [[ $READLINE_LINE == sudo\ * ]]; then 
 #            READLINE_LINE="${READLINE_LINE#sudo }"
#	elif [[ -n $READLINE_LINE ]];then  
#            READLINE_LINE="sudo $READLINE_LINE"
#	fi
#}

#sudo_command
#bind -x '"\C-[s": "sudo_command"'

