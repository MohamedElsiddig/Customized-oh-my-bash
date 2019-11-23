cite about-completion
about-completion 'Bash completion for project plugin'

_pj() {
  [ -z "$PROJECT_PATHS" ] && return
  shift
  [ "$1" == "open" ] && shift

  local cur prev words cword
  _init_completion || return

  local IFS=$'\n' i j k

  compopt -o filenames

  local -r mark_dirs=$(_rl_enabled mark-directories && echo y)
  local -r mark_symdirs=$(_rl_enabled mark-symlinked-directories && echo y)

  for i in ${PROJECT_PATHS//:/$'\n'}; do
    # create an array of matched subdirs
    k="${#COMPREPLY[@]}"
    for j in $( compgen -d $i/$cur ); do
      if [[ ( $mark_symdirs && -h $j || $mark_dirs && ! -h $j ) && ! -d ${j#$i/} ]]; then
        j+="/"
      fi
      COMPREPLY[k++]=${j#$i/}
    done
  done

  if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
    i=${COMPREPLY[0]}
    if [[ "$i" == "$cur" && $i != "*/" ]]; then
      COMPREPLY[0]="${i}/"
    fi
  fi

  return 0
}
if [[ `declare -F pj` ]]
	then
		complete -F _pj -o nospace pj
		complete -F _pj -o nospace pjo
	else
		echo ""
		sleep 1
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo -e "${echo_bold_yellow} [WARRNING]${echo_normal} Project completion requires projects plugin.. Please make sure it's enabled ${echo_normal}"
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan} [INFO]${echo_normal} Disabling it to make sure it dosen't effect the bash startup time${echo_normal}"
		sleep 1
		_disable-completion projects
fi
