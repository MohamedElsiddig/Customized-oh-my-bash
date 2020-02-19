#!/usr/bin/env bash
function bash_stats() {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

#   command_exists: checks for existence of a command (0 = true, 1 = false)
#   -------------------------------------------------------------------
    _command_exists () {
    	 about 'checks for existence of a command'
   		 param '1: command to check'
    	example '$ _command_exists ls && echo exists'
      type "$1" &> /dev/null ;
    }


function uninstall_oh_my_bash() {
  env OSH=$OSH sh $OSH/tools/uninstall.sh
}

function upgrade_oh_my_bash() {
  env OSH=$OSH sh $OSH/tools/upgrade.sh
}

function take() {
  mkdir -p "$1"
  cd "$1" || exit
}

function open_command() {
  local open_cmd

  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   open_cmd='xdg-open' ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac

  # don't use nohup on OSX
  if [[ "$OSTYPE" == darwin* ]]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}

#
# Get the value of an alias.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1 (if it has one).
# Return value:
#    0 if the alias was found,
#    1 if it does not exist
#
function alias_value() {
		about 'Get the value of an alias.'
		group 'lib'
		param 1: alias - The alias to get its value from
		example '$ alias_value ls'
		if [[ -n $1 ]] 
			then
			 alias "$1" | sed "s/^$1='\(.*\)'$/\1/"
			 #test $(alias "$1")
			else
				reference alias_value
		fi
}

#
# Try to get the value of an alias,
# otherwise return the input.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1, or $1 if there is no alias $1.
# Return value:
#    Always 0
#
function try_alias_value() {
		about 'Get the value of an alias.'
		group 'lib'
		param '1: alias - The alias to get its value from'
		example '$ try_alias_value ls'
		if [[ -n $1 ]] 
			then
    			alias_value "$1" || echo "$1"
    		else
				reference try_alias_value
		fi

}

#
# Set variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The variable to set
#    2. val  - The default value
# Return value:
#    0 if the variable exists, 3 if it was set
#
function default() {
		about 'Set variable "$1" to default value "$2" if "$1" is not yet defined.'
		group 'lib'
		param 1: name - The variable to set
		param 2: val  - The default value
		example '$ default variable_name  variable_value'
    typeset -p "$1" &>/dev/null && return 0
    typeset -g "$1"="$2"   && return 3
}

#
# Set enviroment variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The env variable to set
#    2. val  - The default value
# Return value:
#    0 if the env variable exists, 3 if it was set
#
function env_default() {
    env | grep -q "^$1=" && return 0
    export "$1=$2"       && return 3
}

      
###################
# Get weather
function weather() {
  curl -s "wttr.in/$1"
}
######################
#colour man pages

man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;36m") \
    LESS_TERMCAP_md=$(printf "\e[1;36m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;33m") \
    man "$@"
}

#############################


#############################
#List all functions in .bash_functions file
lstfunc(){
  function_name=$1
  grep -v '^ ' ~/.oh-my-bash/lib/functions.sh | sed -n -e '/^.*'"$function_name"'(){/ p' -e '/^.*'"$function_name"'() {/ p'
}		
#########################
#quicly get cheat sheet to something (eg: cheatsheet bash)
cheatsheet() {
		about 'Quicly get cheat sheet to something from https://cheat.sh website.'
		group 'lib'
		param '1: The Cheatsheets you want to get '
		example '$ cheatsheet ls'
    # Cheatsheets https://github.com/chubin/cheat.sh
    if [ "$1" == "" ]; then
    	reference cheatsheet
        
    else
    	curl -L "https://cheat.sh/$1"
    fi
}

##########################

#get cheatsheets from devhints.io website

devhints(){
		about 'Get cheatsheets from devhints.io website.'
		group 'lib'
		param '1: The Cheatsheets you want to get'
		param '2 Optinal: --refresh to refresh the local cheatsheets if found '
		example '$ devhints bash'
		example '$ devhints bash --refresh'
type wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed."; exit 1; }
type bat >/dev/null 2>&1 || { echo >&2 "I require bat but it's not installed."; exit 1; }

if [[ -z ${1} ]]
then
reference devhints; return 0
else 
TOOL=${1}
fi
REFRESH=${2:-no}

RAW_MD_URL="https://raw.githubusercontent.com/rstacruz/cheatsheets/master/${TOOL}.md"

CACHE_DIR=$HOME/.hack/
LOCAL_CACHE_FILE=$CACHE_DIR/${TOOL}.md

if [ ! -d $CACHE_DIR ]; then
  mkdir -p $CACHE_DIR
fi

if [ "$REFRESH" == "--refresh" ] || [ ! -e $LOCAL_CACHE_FILE ]; then
  wget -q -O - $RAW_MD_URL | sed -e '/^{: /d' > $LOCAL_CACHE_FILE
fi

if [ -s $LOCAL_CACHE_FILE ]; then
  bat $LOCAL_CACHE_FILE 2>/dev/null
else
  echo No cheat sheet found!
  rm -rf $LOCAL_CACHE_FILE > /dev/null 2>&1
fi
}
# converts and saves youtube video to mp3
function convert_to_mp3() {
	about 'converts and saves youtube video to mp3.'
	group 'misc'
	param '1: The URL of youtube video.'
	example '$ convert_to_mp3 URL'
	if [[ -z $1 ]]
		then
			reference convert_to_mp3
		else
			youtube-dl --extract-audio --audio-format mp3 $1
	fi
}

function playlist_download() {
	about 'Download and saves youtube playlists.'
	group 'misc'
	param '1: The URL of youtube video.'
	example '$ playlist_download URL'
	if [[ -z $1 ]]
		then
			reference playlist_download
		else
			youtube-dl -i -f mp4 --yes-playlist $1
	fi
}

alias hint='devhints'
