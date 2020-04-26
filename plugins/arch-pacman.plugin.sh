#!/usr/bin/env bash
cite about-plugin

about-plugin 'Helpfull functions for arch based distros.'


function pkgupgrade(){
about 'Searches the system and upgrade multiple packages.'
group 'misc'
has() {
  local verbose=0
  if [[ $1 = '-v' ]]; then
    verbose=1
    shift
  fi
  for c; do c="${c%% *}"
    if ! command -v "$c" &> /dev/null; then
      (( "$verbose" > 0 )) && err "$c not found"
      return 1
    fi
  done
}

err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2
}

die() {
  (( $# > 0 )) && err "$*"
  exit 1
}

select_from() {
  local cmd='command -v'
  for a; do
    case "$a" in
      -c)
        cmd="$2"
        shift 2
        ;;
    esac
  done
  for c; do
    if $cmd "${c%% *}" &> /dev/null; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

has -v fzf || die

helper=$(select_from pacaur trizen packer apacman pacman)

mapfile -t pkgs < <(
  $helper -Qu --color=always |
  fzf --ansi -e -m --inline-info --cycle --reverse --bind='Ctrl-A:toggle-all' |
  awk '{print $3}'
)

count="${#pkgs[@]} package"
(( ${#pkgs[@]} > 1 )) && count+='s'
printf "upgrading %s: %s\n" "$count" "${pkgs[*]}"

(( ${#pkgs[@]} > 0 )) && $helper -S "${pkgs[@]}"
}




function pkgremove(){
about 'Searches repos and remove multiple packages.'
group 'misc'
declare by_size

has() {
  local verbose=0
  if [[ $1 = '-v' ]]; then
    verbose=1
    shift
  fi
  for c; do c="${c%% *}"
    if ! command -v "$c" &> /dev/null; then
      (( "$verbose" > 0 )) && err "$c not found"
      return 1
    fi
  done
}

err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2
}

die() {
  (( $# > 0 )) && err "$*"
  return  1
}

select_from() {
  local o c cmd OPTARG OPTIND
  cmd='command -v'
  while getopts 'c:' o; do
    case "$o" in
      c) cmd="$OPTARG" ;;
    esac
  done
  shift "$((OPTIND-1))"
  for c; do
    if $cmd "${c%% *}" &> /dev/null; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

has -v fzf expac || die

fzf() {
  command fzf -e --multi --no-hscroll --inline-info --ansi --cycle --bind='Ctrl-a:toggle-all' "$@"
}

case $1 in
  -s|--size) by_size=1; shift;
esac

if (( $# > 0 )); then
  sudo pacman -Rcusn "$@"
  return 
fi

preview=$(select_from pacaur pacman)

if (( by_size )); then
  mapfile -t pkgs < <(expac -H M '%m\t%n' | sort -hr | fzf +s --preview="$preview --color=always -Si {3}" -q '!^lib ' | cut -f2)
else
  mapfile -t pkgs < <(expac '%n' | fzf +s --preview="$preview --color=always -Si {1}" -q '!^lib ' | cut -d' ' -f1)
fi

(( ${#pkgs[@]} > 0 )) && sudo pacman -Rcusn "${pkgs[@]}"
}


function pkglist(){

if [[ `command -v  expac` ]]
    then
        pacs=$(expac -Qs --timefmt="%y/%m/%d" "%l|{%w}{%G}%n|%d" | \
	        grep -v -E "{dependency}|{xorg.*}|{base.*}" | \
	        sort | \
	        sed 's|{[^}]*}||g')

        num_of_pacs=$(echo "$pacs" | wc -l)

        echo "$pacs" | column -s "|" -t -o " | " -W3
        printf "\nTotal: %d\n" "$num_of_pacs"
    else
    echo "To use this function you need expac command please download it"
fi
}
