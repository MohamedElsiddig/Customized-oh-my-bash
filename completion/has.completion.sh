cite about-completion
about-completion 'Bash completion for has plugin'

_has() {
local cur prev
cur="${COMP_WORDS[COMP_CWORD]}"
prev="${COMP_WORDS[COMP_CWORD-1]}"
words="has zip hub apt-offline sbt gor gulp go hugo scala kotlin ant java javac ab clear ssh unzip apache2 figlet aws eb sls gcloud lein groovy gradle mvn perl perl6 php php5 tor python python3 ruby gem rake bundle cmake grunt brunch node npm yarn tar pv wine ls fzf R gzip xz unar bzip2 msfconsole sed awk grep file sudo find less cat tree apt apt-get aptitude apt-cache dpkg jq ag brew bats tree ack autojump bat vim emacs nano subl pip pip3 curl wget http ufw samba tldr aria2c gcc make g++ git hg svn bzr man bash zsh golang go jre java jdk javac nodejs node goreplay gor httpie http homebrew brew awsebcli eb awscli aws aria2 aria2c coreutils gnu_coreutils systemctl systemd" 

COMPREPLY=($(compgen -W "${words}" -- "${cur}"))

}

if [[ `declare -F has` ]]
	then
 		complete -o default -F _has has
 	else
 		echo ""
 		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
 		sleep 1
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} has completion requires has plugin.. Please make sure it's enabled${echo_normal}" 
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it doesn't effect the bash startup time
		${echo_normal}"
		sleep 1
		_disable-completion has 
fi
