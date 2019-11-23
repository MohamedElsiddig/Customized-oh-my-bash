# Copies the pathname of the current directory to the system or X Windows clipboard
cite about-plugin
about-plugin 'Copies the pathname of the current directory to the system or X Windows clipboard'
function copydir {
	about 'Copies the pathname of the current directory to the system or X Windows clipboard'
	group 'misc'
	if [[ `declare -F clipcopy`  ]]
		then  
			printf $PWD | clipcopy
		else
			sleep 1
			echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} Copydir plugin requires clipboard plugin.. Please make sure it's enabled${echo_normal}" 
			echo ""
			sleep 1
			echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
			${echo_normal}"
			sleep 1
			_disable-plugin copydir
	fi
}
