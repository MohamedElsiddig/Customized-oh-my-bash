
cite about-plugin
about-plugin 'Cod is a completion daemon It detects usage of --help commands parses their output and generates auto-completions for your shell.'

if [[ `command -v  cod` ]]
	then
        source <(cod init $$ bash)
	else
        echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} cod is not found in your path please install and reEnable this plugin${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-plugin cod 
fi

