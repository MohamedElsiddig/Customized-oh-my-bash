# Copies the contents of a given file to the system or X Windows clipboard
cite about-plugin
about-plugin 'Copies the contents of a given file to the system or X Windows clipboard'
# copyfile <file>
function copyfile {
	about 'Copies the contents of a given file to the system or X Windows clipboard'
	group 'misc'
	if [[ `declare -F clipcopy`  ]]
		then  
  			clipcopy $1
  		else
  			sleep 1
			echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} Copyfile plugin requires clipboard plugin.. Please make sure it's enabled" 
			echo ""
			sleep 1
			echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it  doesn't effect the bash startup time
			"
			sleep 1
			_disable-plugin copyfile 
	fi
}
