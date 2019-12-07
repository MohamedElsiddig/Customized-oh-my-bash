# Load after the system completion to make sure that the fzf completions are working
# BASH_IT_LOAD_PRIORITY: 375

cite about-plugin
about-plugin 'load fzf, if you are using it'

if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash
elif [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
fi

if [ -z ${FZF_DEFAULT_COMMAND+x}  ]; then
  command -v fd &> /dev/null && export FZF_DEFAULT_COMMAND='fd --type f'
fi

fe() {
  about "Open the selected file in the default editor"
  group "fzf"
  param "1: Search term"
  example "fe foo"

  local IFS=$'\n'
  local files
  files=($(fzf --reverse --border --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-gedit} "${files[@]}"
}

fcd() {
  about "cd to the selected directory"
  group "fzf"
  param "1: Directory to browse, or . if omitted"
  example "fcd aliases"

  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m --reverse --border) &&
  cd "$dir"
}


vf() {
  about "Use fasd to search the file to open in vim"
  group "fzf"
  param "1: Search term for fasd"
  example "vf xml"

  local file
  file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m --reverse --border)" && vi "${file}" || return 1
}

#old fman function

#fman() {
#  about "Quickly display a man page using fzf"
#  group "fzf"
#  example "fman"

#    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
#}

fman() {

	about "Quickly display a man page using fzf"
	group "fzf"
	example "fman"

	RED="$(tput setaf 1 2> /dev/null)"
	YELLOW="$(tput setaf 3 2> /dev/null)"
	CYAN="$(tput setaf 6 2> /dev/null)"
	RESET="$(tput sgr0 2> /dev/null)"

	export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
	export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
	export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
	export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
	export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
	export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
	export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
	export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

	: "${MAN_PATH:=/usr/share/man/}"
	: "${MAN_EXT:=gz}"
	function get_manpages() { # {{{
		find "${MAN_PATH}" -iname "*.${MAN_EXT}" -printf '%f\n' | \
			sed -e 's/\.'"${MAN_EXT}"'//g' | \
			awk -F '.' '
				BEGIN {
					mantype[1] = "Commands"
					mantype[2] = "System calls"
					mantype[3] = "Library calls"
					mantype[4] = "Special files"
					mantype[5] = "File formats"
					mantype[6] = "Games"
					mantype[7] = "Miscellaneous"
					mantype[8] = "System administration commands"
					mantype[9] = "Kernel routines"
				} {
					printf "%-50s '"$CYAN"'%s'"$RESET"'\n", $0, mantype[substr($NF,1,1)]
				}
		' \
			| sort -u
	}


	function search() { 
	local header
	header="$(printf '%-50s %s' 'Manpage' 'Section')"
	fzf --border --reverse --ansi --prompt='manpage: ' --inline-info -0 --header "$header"
	}

		get_manpages | search | awk '{print $1}' | xargs -r man
}


function fzmv(){
  about "move files ineractivelly"
  group "fzf"
  example "fzmv"

declare -r esc=$'\033'
declare -r c_reset="${esc}[0m"
declare -r c_red="${esc}[31m"
declare dryrun verbose

#set -e

err() {
  printf "${c_red}%s${c_reset}\n" "$*" >&2
}

die() {
  return 1
}

has() {
  local verbose=0
  if [[ $1 == '-v' ]]; then
    verbose=1
    shift
  fi
  for c; do c="${c%% *}"
    if ! command -v "$c" &> /dev/null; then
      (( verbose > 0 )) && err "$c not found"
      return 1
    fi
  done
}

has -v fzf || die

fzf() {
  command fzf --cycle --reverse --border "$@"
}

pick_files() {
  local files fzpick
  find . -maxdepth 1 2> /dev/null |
    sort -h |
    sed '1d; s|^\./||' |
    while read -r f; do
      if [[ -d "$f" ]]; then
        printf '%s/\n' "$f"
      elif [[ -L "$f" ]]; then
        printf '%s@\n' "$f"
      else
        printf '%s\n' "$f"
      fi
    done |
    fzf --multi --header='move these files'  || return 1
}

pick_destination() {
  local cwd browse_dir browse_info query dirs
  cwd=$(pwd)
  while [[ "$browse_dir" != "$cwd" ]]; do
    mapfile -t browse_info < <(
    { echo '..'; find . -maxdepth 1 -type d 2> /dev/null; } |
      sed 's|^./||' |
      sort -h |
      fzf --print-query \
      --history="${HOME}/.cache/fzmv_history" \
      --header="${errors:-move files here}")
    query=${browse_info[0]}
    browse_dir=${browse_info[1]}
    files=( "${browse_info[@]:2}" )
    [[ -d "$query" ]] && browse_dir="$query"
    [[ ! -d "$browse_dir" ]] && return 1
    if [[ "$browse_dir" == '.' && $(realpath "$browse_dir") != "$cwd" ]]; then
      realpath "$browse_dir"
      break
    else
      cd "$browse_dir" || die
      continue
    fi
  done
}

while (( $# > 0 )); do
  case $1 in
    -t|--test) dryrun=true ;;
    -v|--verbose) verbose=1 ;;
  esac
  shift
done

mapfile -t files < <(pick_files)
(( ${#files[@]} > 0 )) || return 1
destination=$(pick_destination) || return 1
${dryrun:+echo} mv ${verbose:+-v} -t "$destination" "${files[@]}"
}
