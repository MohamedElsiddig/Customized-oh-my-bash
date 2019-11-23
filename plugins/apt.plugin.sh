cite about-plugin
about-plugin 'Helpfull functions for Ubuntu and Debian distros'
# Misc. #####################################################################

if [[ `which apt` ]]
	then
		APT=apt
	else
		APT=apt-get
fi
#apt-history
function apt-history(){
		about 'Show apt history for specific event.'
		group 'misc'
		param '1: verb [one of: upgrade | install | remove | rollback ] '
		example '$ apt-history install'
      case "$1" in
        install)
              cat /var/log/dpkg.log | grep --color=auto 'install '
              ;;
        upgrade|remove)
              cat /var/log/dpkg.log | grep --color=auto $1
              ;;
        rollback)
              cat /var/log/dpkg.log | grep --color=auto upgrade | \
                  grep "$2" -A10000000 | \
                  grep "$3" -B10000000 | \
                  awk '{print $4"="$5}'
              ;;
        *)
              reference apt-history
              ;;
      esac
      }


# apt-add-repository with automatic install/upgrade of the desired package
# Usage: aar ppa:xxxxxx/xxxxxx [packagename]
# If packagename is not given as 2nd argument the function will ask for it and guess the default by taking
# the part after the / from the ppa name which is sometimes the right name for the package you want to install
aar() {
	about 'apt-add-repository with automatic install/upgrade of the desired package'
	group 'misc'
	param '1: The ppa URL'
	param '2: Package name'
	example '$ aar ppa:xxxxxx/xxxxxx [packagename]'
	if [[ -z $1 ]]
		then
			reference aar
	else
		if [ -n "$2" ]; then
			PACKAGE=$2
		else
			read "PACKAGE?Type in the package name to install/upgrade with this ppa [${1##*/}]: "
		fi
		
		if [ -z "$PACKAGE" ]; then
			PACKAGE=${1##*/}
		fi
		
		sudo apt-add-repository $1 && sudo $APT update
		sudo $APT install $PACKAGE
	fi
}


# Kernel-package building shortcut
kerndeb () {
	
    # temporarily unset MAKEFLAGS ( '-j3' will fail )
    MAKEFLAGS=$( print - $MAKEFLAGS | perl -pe 's/-j\s*[\d]+//g' )
    print '$MAKEFLAGS set to '"'$MAKEFLAGS'"
	appendage='-custom' # this shows up in $ (uname -r )
    revision=$(date +"%Y%m%d") # this shows up in the .deb file name

    make-kpkg clean

    time fakeroot make-kpkg --append-to-version "$appendage" --revision \
        "$revision" kernel_image kernel_headers
}

# List packages by size
function apt-list-packages {
		about 'List packages by size'
		group 'misc'
		dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | \
    	grep -v deinstall | \
    	sort -n | \
    	awk '{print $1" "$2}'
}

# Purge old kernels from boot directory
#------------------------------------------------------------------
function clean_old_kernels(){
current_kernel="$(uname -r | sed 's/\(.*\)-\([^0-9]\+\)/\1/')"
current_ver=${current_kernel/%-generic}

echo "Running kernel version is: ${current_kernel}"
# uname -a

function xpkg_list() {
    dpkg -l 'linux-*' | sed '/^ii/!d;/linux-libc-dev/d;/'${current_ver}'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d'
}

echo "The following (unused) KERNEL packages will be removed:"
xpkg_list

read -p 'Do you want to continue [yN]? ' -n 1 -r
printf "\n"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    xpkg_list | xargs sudo apt-get -y purge
else
    echo 'Operation aborted. No changes were made.'
fi
}
#Automatically enable apt-history function completion

# _OSH-component-item-is-enabled completion apt-history

# if [[ "$?" != "0" ]] && [[ "${AUTO_ENABLING}" == "enable" ]]
# 	then
# 		source "${OSH}/themes/colours.theme.sh"
# 		source "${OSH}/themes/base.theme.sh"
# 		echo ""
# 		echo -e "${echo_bold_green} Enabling apt-history function completion${echo_normal}"
# 		sleep 1
# 		_enable-completion apt-history

# fi


# Searches installed and remove multiple packages
#------------------------------------------------------------------
function pkgremove(){
about 'Searches repos and remove multiple packages.'
group 'misc'
declare -r esc=$'\033'
declare -r c_reset="${esc}[0m"
declare -r c_red="${esc}[31m"
declare -r c_green="${esc}[32m"
declare -r c_blue="${esc}[34m"
declare distro

declare preview_pos='right:hidden'

usage() {
  LESS=-FEXR less <<HELP
pkgsearch [options] [query]
  lists and installs packages from your distro's repositories

  without any arguments pkgsearch will list all available packages from your cache
  note: on Arch Linux you must pass a string to query the AUR
HELP
}

err() {
  printf "${c_red}%s${c_reset}\n" "$*" >&2
}

die() {
  exit 1
}

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

fzf() {
  command fzf -e +s --multi --cycle --ansi \
    --bind='Ctrl-X:toggle-preview' \
    --no-hscroll --inline-info \
    --header='tab to select multiple packages, Ctrl-X for more info on a package' "$@"
}

remove() {
  local pkgs count
  mapfile -t pkgs
  (( ${#pkgs} > 0 )) || exit
  count="${#pkgs[@]} package"
  (( ${#pkgs[@]} > 1 )) && count+='s'
  printf "removeing %s: %s\n" "$count" "${pkgs[*]}"
  $1 "${pkgs[@]}" < /dev/tty
}

debian() {
  fzf --preview='apt-cache show {1}' \
      --query="$1" \
    < <(dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n'| awk '{print $2}' | sort |
      sed -u -r "s|^([^ ]+)|${c_green}\1${c_reset}|") |
    cut -d' ' -f1 |
    remove "sudo $(select_from 'apt' 'aptitude' 'apt-get') autoremove"
}



while true; do
  case "$1" in
    -h|--help) usage; exit ;;
    -p|--preview) preview_pos="$2"; shift 2 ;;
    *) break
  esac
done

has -v fzf gawk || die

request="$*"

if [[ -r /etc/os-release ]]; then
  distro=$(awk -F'=' '"NAME" == $1 { gsub("\"", "", $2); print tolower($2); }' /etc/os-release)
  distro="${distro%% *}"
fi

case "$distro" in
  debian|ubuntu) debian "$request" ;;
#  arch) arch "$request" ;;
#  void) void "$request" ;;
#  fedora) fedora "$request" ;;
  *) die 'unknown distro :(' ;;
esac
}



