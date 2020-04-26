#!/usr/bin/env bash
#  ---------------------------------------------------------------------------
cite about-plugin
about-plugin 'This plugin holds all base BASH functions'
#  Description:  This file holds all base BASH functions
#
#  Sections:
#  1.   Make Terminal Better (remapping defaults and adding functionality)
#  2.   File and Folder Management
#  3.   Searching
#  4.   Process Management
#  5.   Networking
#  6.   System Operations & Information
#  7.   Date & Time Management
#  8.   Web Development
#  9.   <your_section>
#
#  X.   Reminders & Notes
#
#  ---------------------------------------------------------------------------

#   -----------------------------
#   1.  MAKE TERMINAL BETTER
#   -----------------------------

#   mkcd:   Makes new Dir and jumps inside
#   --------------------------------------------------------------------
function mkcd(){
		about 'Makes new Dir and jumps inside.'
		group 'base'
		param '1: The name of the new Dir.'
		example '$ mkcd dir_name'
    if [[ -z $1 ]]
      then
        reference mkcd
      else
        mkdir -p -v $1
        cd $1
    fi
}
#   up:   jump to previous dir using numbers
#   --------------------------------------------------------------------
function up(){
		about 'jump to previous dir using numbers.'
		group 'base'
		param '1: Number of Directory to jumps.'
		example '$ up 2'
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.
#           Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () { 
    about 'Search manpage given in agument '1' for term given in argument '2' (case insensitive).'
		group 'base'
		param '1: man page.'
		param '2: the term you want to search.'
		example '$ mans mplayer codec'
    man "$1" | grep -iC2 --color=always "$2" | less ; 
    }

#   showa: to remind yourself of an alias (given some part of it)
#   ------------------------------------------------------------
    showa () { 
    about 'Remind yourself of an alias (given some part of it).'
		group 'base'
		param '1: alias name or part of it'
		example '$ showa ls'
    
    /bin/grep --color=always -i -a1 "$@" ~/.oh-my-bash/aliases/*.aliases.sh | grep -v '^\s*$' | less -FSRXc ; 
    }

#   quiet: mute output of a command
#   ------------------------------------------------------------
    quiet () {
        "$*" &> /dev/null &
    }

#   lsgrep: search through directory contents with grep
#   ------------------------------------------------------------
# shellcheck disable=SC2010
    lsgrep () { ls | grep "$*" ; }

#   banish-cookies: redirect .adobe and .macromedia files to /dev/null
#   ------------------------------------------------------------
    banish-cookies () {
    	about 'redirect .adobe and .macromedia files to /dev/null'
    	group 'base'
      rm -r ~/.macromedia ~/.adobe
      ln -s /dev/null ~/.adobe
      ln -s /dev/null ~/.macromedia
    }

#   show the n most used commands. defaults to 10
#   ------------------------------------------------------------
    hstats() {
    about 'show the n most used commands. defaults to 10'
    group 'base'
      if [[ $# -lt 1 ]]; then
        NUM=10
      else
        NUM=${1}
      fi
      history | awk '{print $2}' | sort | uniq -c | sort -rn | head -"$NUM"
    }



# mkexecute:  Creates executable bash script, or python scripts or
#              just changes modifiers to executable, if file already exists.
#     ---------------------------------------------------------

mkexecute() {
		about 'Creates executable bash script | python script, or just changes modifiers to executable, if file already exists.'
		group 'base'
		param '1: The new Executable name | The file name'
		example '$ mkexecute file_name.<sh>|<py>'

  if [[ ! -f "$1" ]]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    if [[ "$extension" == "py" ]]; then
      echo '#!/usr/bin/env python3' >> "$1"
      echo '#' >> "$1"
      echo "# Usage: $1 " >> "$1"
      echo '# ' >> "$1"
      echo >> "$1"
      echo 'import sys' >> "$1"
      echo 'import re' >> "$1"
      echo >> "$1"
      echo 'def main():' >> "$1"
      echo '    ' >> "$1"
      echo >> "$1"
      echo "if __name__ == '__main__':" >> "$1"
      echo '    main()' >> "$1"
    elif [[ "$extension" == "sh" ]]; then
      echo '#!/bin/bash' >> "$1"
      echo '# Shell Script Template' >> "$1"
      echo "#/ Usage: $1 " >> "$1"
      echo "#/ Description: " >> "$1"
      echo "#/ Options: " >> "$1"
      echo '# ' >> "$1"
      echo "#Colors" >> "$1"
      echo "
normal='\e[0m'
cyan='\e[0;36m'
green='\e[0;32m'
light_green='\e[1;32m'
white='\e[0;37m'
yellow='\e[1;49;93m'
blue='\e[0;34m'
light_blue='\e[1;34m'
orange='\e[38;5;166m'
light_cyan='\e[1;36m'
red='\e[1;31m' 
      " >> "$1"
      echo "function usage() { grep '^#/' "$1" | cut -c4- ; exit 0 ; }" >> "$1"
      echo >> "$1"
      echo "# Logging Functions to log what happend in the script [It's recommended]" >> "$1"
      echo "" >> "$1"
      echo "readonly LOG_FILE=\"/tmp/\$(basename \"\$0\").log\"" >> "$1"
      echo "
    info()    { echo -e \"\$light_cyan[INFO]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    warning() { echo -e \"\$yellow[WARNING]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    error()   { echo -e \"\$red[ERROR]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    fatal()   { echo -e \"\$orange[FATAL]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; exit 1 ; }
      
      " >> "$1"
      echo '# Stops execution if any command fails.' >> "$1"
      echo 'set -eo pipefail' >> "$1"
      
      echo >> "$1"
      echo "function cleanup() {" >> "$1"
      echo "  # Remove temporary files
    # Restart services
    # ..." >> "$1"
      echo "  echo \"\"" >> "$1"
      echo "}" >> "$1"
      echo >> "$1"
      echo 'function main() {'>> "$1"
      echo "  if [[ \$1 = \"--help\" ]]" >> "$1" 
      echo "	then" >> "$1"
      echo '    expr "$*" : ".*--help" > /dev/null && usage'>> "$1"
      echo '	else' >> "$1"
      echo '    # Some Code Here'   >> "$1"
      echo "    echo \"some code here\"" >> "$1"
      echo "  fi" >> "$1"
      echo "" >> "$1"
      echo "#trap command make sure the cleanup function run to clean any miss created by the script" >> "$1"
      echo >> "$1"
      echo "trap cleanup EXIT" >> "$1"
      echo >> "$1"
      echo '}'>> "$1"
      echo >> "$1"
      echo "#This test is used to execute the main code only when the script is executed directly, not sourced" >> "$1"
      echo "
if [[ \"\${BASH_SOURCE[0]}\" = \"\$0\" ]]; then
    # Main code of the script
      " >> "$1"
      echo 'main "$@"'>> "$1"
       echo "
      info  this is information
      warning  this is warning
      error  this is Error
      fatal  this is Fatal
      " >> "$1"
      echo "fi" >> "$1"
      echo "" >> "$1"
      echo "" >> "$1"
    else
      reference mkexecute
    fi
  fi
  if [[ ! -z "$1" ]]; then
  chmod u+x "$@"
  else
  true
  fi           
}

#   -------------------------------
#   2.  FILE AND FOLDER MANAGEMENT
#   -------------------------------

#zipf () { zip -r "$1".zip "$1" ; }           # zipf:         To create a ZIP archive of a folder

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
   
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function extract() {
		about 'Extract most known archives with one command .'
		group 'base'
		param '1: The file name you want to extract'
		example '$ extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>'
		example '$ extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]'
 if [ -z "$1" ]; then
    # display usage if no parameters given
    reference extract
 else
    for n in "$@"
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tar.zst|*.tbz2|*.tgz|*.txz|*.tar) 
                         tar xvf "$n"       ;;
            *.lzma)      unlzma "$n"      ;;
            *.bz2)       bunzip2 "$n"     ;;
            *.cbr|*.rar)       unrar x -ad "$n" ;;
            *.gz)        gunzip "$n"      ;;
            *.cbz|*.epub|*.zip|*.apk|*.xapk)       unzip "$n" -d "${n:0:-4}"    ;;
            *.z)         uncompress "$n"  ;;
            *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                         7z x "$n"        ;;
            *.xz)        unxz "$n"        ;;
            *.exe)       cabextract "$n"  ;;
            *.cpio)      cpio -id < "$n"  ;;
            *.cba|*.ace)      unace x "$n"      ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}

IFS=$SAVEIFS


#     Open filetype
#     oft:  Finds every file in folder whose extension starts with the first parameter passed
#           if more than one file of given type is found, it offers a menu
# ----------------------------------------------------------------------------
oft () {
		about 'Finds every file in folder whose extension starts with the first parameter passed if more than one file of given type is found, it offers a menu'
		group 'base'
		param '1: An extension or partial extension'
		example "$ oft sh"
  if [[ $# == 0 ]]; then
    echo -n "Enter an extension or partial extension: "
    read extension
  fi
  if [[ $# > 1 ]]; then
    reference oft
    return
  fi
  extension=$1

  ls *.*$extension* > /dev/null
  if [[ $? == 1 ]]; then
    echo "No files matching \"$extension\" found."
    return
  fi
  declare -a fileList=( *\.*$extension* )

  if [[ ${#fileList[*]} -gt 1 ]]; then
    IFS=$'\n'
    PS3='Open which file? '
    select OPT in "Cancel" ${fileList[*]} "Open ALL"; do
      if [ $OPT == "Open ALL" ]; then
        read -n1 -p "Open all matching files? (y/N): "
        [[ $REPLY = [Yy] ]] && $(/usr/bin/xdg-open  ${fileList[*]})
      elif [ $OPT != "Cancel" ]; then
        $(/usr/bin/xdg-open  "$OPT")
      fi
      unset IFS
      break
    done
  else
    $(/usr/bin/xdg-open "${fileList[0]}")
  fi
}





#   mkarchive:  compress a directory
#   ---------------------------------------------------------

function mkarchive(){
		about 'Create a compress file form a directory.'
		group 'base'
		param '1: The Compress Method [ zip | tgz | tar | bz2 | 7z | zstd]'
		param '2: The output file name'
		param '3: The Directory to compress'
		example '$ mkarchive zip Shell-scripts ~/Docuoments/Shell-scripts'
		example '$ mkarchive tgz Shell-scripts ~/Docuoments/Shell-scripts'
		param '** In the 7z method choose the compression level'
		example '$ mkarchive 7z [ 1 | 3 | 5 | 7 | 9 ] Shell-scripts ~/Docuoments/Shell-scripts'
		param   '** Note in 7z 9 considered ultra compression ... the default is 5'
	if [[ ! -z $1 ]]
		then
			case $1 in
				  bz2)	tar  cvjf  "$2.tar.bz2" -C "$3" . ;;
				  tgz)	tar cvzf   "$2.tar.gz" -C "$3" .  ;;
				  tzstd)	tar --zstd  -cvf "$2.tar.zst" -C "$3" .  ;;
				  tar)	tar cvf    "$2.tar"   -C "$3" .  ;;
				  zip)	zip -r "$2".zip "$3" ;;
				   7z)  7z a -mx=$2 "$3".7z $4 ;;
				  *)   	reference mkarchive ;;
				 esac
     	else
         	reference mkarchive
     fi	
}



#   buf:  back up file with timestamp
#   ---------------------------------------------------------
    buf () {
      local filename filetime
      filename=$1
      filetime=$(date +%Y%m%d_%H%M%S)
      cp -a "${filename}" "${filename}_${filetime}"
    }

#   del:  move files to hidden folder in tmp, that gets cleared on each reboot
#   ---------------------------------------------------------
    del() {
      mkdir -p /tmp/.trash && mv "$@" /tmp/.trash;
    }

#   mkiso:  creates iso from current dir in the parent dir (unless defined)
#   ---------------------------------------------------------
    mkiso () {
    about 'creates iso from current dir in the parent dir (unless defined)'
    param '1: ISO name'
    param '2: dest/path'
    param '3: src/path'
    example 'mkiso'
    example 'mkiso ISO-Name dest/path src/path'
    group 'base'

    if type "mkisofs" > /dev/null; then
        [ -z ${1+x} ] && local isoname=${PWD##*/} || local isoname=$1
        [ -z ${2+x} ] && local destpath=../ || local destpath=$2
        [ -z ${3+x} ] && local srcpath=${PWD} || local srcpath=$3

        if [ ! -f "${destpath}${isoname}.iso" ]; then
            echo "writing ${isoname}.iso to ${destpath} from ${srcpath}"
            mkisofs -V ${isoname} -iso-level 3 -r -o "${destpath}${isoname}.iso" "${srcpath}"
        else
            echo "${destpath}${isoname}.iso already exists"
        fi
    else
        echo "mkisofs cmd does not exist, please install cdrtools"
    fi
    }

# Creates an archive from given directory

function mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
function mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
function mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }


#   ---------------------------
#   3.  SEARCHING
#   ---------------------------

#   findend: find out the file by it's extension
#   -----------------------------------------------------
function findend (){
    find . -type f -name \*.${1}
}
#   -----------------------------------------------------
findfile () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
# shellcheck disable=SC2145

bigfind() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: bigfind DIRECTORY"
    return
  fi
  du -a "$1" | sort -n -r | head -n 10
}


#   ---------------------------
#   4.  PROCESS MANAGEMENT
#   ---------------------------

#   findPid: find out the pid of a specified process
#   -----------------------------------------------------
#       Note that the command name can be specified via a regex
#       E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
#       Without the 'sudo' it will only find processes of the current user
#   -----------------------------------------------------
    findPid () { lsof -t -c "$@" ; }

#   my_ps: List processes owned by my user:
#   ------------------------------------------------------------
    my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command ; }


#   ---------------------------
#   5.  NETWORKING
#   ---------------------------

#   ips:  display all ip addresses for this host
#   -------------------------------------------------------------------
    ips () {
    	about 'display all ip addresses for this host'
    	group 'base'
    	
      if command -v ifconfig &>/dev/null
      then
        ifconfig | awk '/inet /{ print $2 }'
      elif command -v ip &>/dev/null
      then
        ip addr | grep -oP 'inet \K[\d.]+'
      else
        echo "You don't have ifconfig or ip command installed!"
      fi
    }
    
#   wifikey:  Get saved WiFi keys
#   ---------------------------------------------------------------- 
   function wifikey()
     {
     	about 'Get saved WiFi keys'
    	group 'base'
        sudo grep -r '^psk=' /etc/NetworkManager/system-connections/ | cut -f5 -d'/'
     }

#   down4me:  checks whether a website is down for you, or everybody
#   -------------------------------------------------------------------
    down4me () {
    	about 'checks whether a website is down for you, or everybody'
    	param '1: website url'
    	example '$ down4me http://www.google.com'
    	group 'base'
      curl -s "http://www.downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
    }

#   myip:  displays your ip address, as seen by the Internet
#   -------------------------------------------------------------------
    myip () {
    	about 'displays your ip address, as seen by the Internet'
    	group 'base'
      res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
      echo -e "Your public IP is: ${echo_bold_green} $res ${echo_normal}"
    }

#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
    ii() {
      echo -e "\\nYou are logged on ${red}$HOST"
      echo -e "\\nAdditionnal information:$NC " ; uname -a
      echo -e "\\n${red}Users logged on:$NC " ; w -h
      echo -e "\\n${red}Current date :$NC " ; date
      echo -e "\\n${red}Machine stats :$NC " ; uptime
      [[ "$OSTYPE" == darwin* ]] && echo -e "\\n${red}Current network location :$NC " ; scselect
      echo -e "\\n${red}Public facing IP Address :$NC " ;myip
      [[ "$OSTYPE" == darwin* ]] && echo -e "\\n${red}DNS Configuration:$NC " ; scutil --dns
      echo
    }

# wirelessNetworksInRange:  Displays wireless networks in range.
#_________________________________________________________________________
wirelessNetworksInRange() {
 sudo iwlist wlp2s0 scan \
    | grep Quality -A2 \
    | tr -d "\n" \
    | sed 's/--/\n/g' \
    | sed -e 's/ \+/ /g' \
    | sort -r \
    | sed 's/ Quality=//g' \
    | sed 's/\/70 Signal level=-[0-9]* dBm Encryption key:/ /g' \
    | sed 's/ ESSID:/ /g'
}

#   ---------------------------------------
#   6.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

#   batch_chmod: Batch chmod for all files & sub-directories in the current one
#   -------------------------------------------------------------------
    batch_chmod() {
      echo -ne "${echo_bold_blue}Applying 0755 permission for all directories..."
      (find . -type d -print0 | xargs -0 chmod 0755) &
      spinner
      echo -ne "${echo_normal}"
      
      echo -ne "${echo_bold_blue}Applying 0644 permission for all files..."
      (find . -type f -print0 | xargs -0 chmod 0644) &
      spinner
      echo -ne "${echo_normal}"
    }

#   usage: disk usage per directory, in Mac OS X and Linux
#   -------------------------------------------------------------------
    usage () {
    	about 'disk usage per directory, in Mac OS X and Linux'
    	param '1: directory name'
    	group 'base'
      if [ "$(uname)" = "Darwin" ]; then
        if [ -n "$1" ]; then
          du -hd 1 "$1"
        else
          du -hd 1
        fi
      elif [ "$(uname)" = "Linux" ]; then
        if [ -n "$1" ]; then
          du -h --max-depth=1 "$1"
        else
          du -h --max-depth=1
        fi
      fi
    }


#   pickfrom: picks random line from file
#   -------------------------------------------------------------------
    pickfrom () {
    about 'picks random line from file'
    param '1: filename'
    example '$ pickfrom /usr/share/dict/words'
    group 'base'
    local file=$1
    [ -z "$file" ] && reference $FUNCNAME && return
    length=$(cat $file | wc -l)
    n=$(expr $RANDOM \* $length \/ 32768 + 1)
    head -n $n $file | tail -1
    }

#   passgen: generates random password from dictionary words
#       Note default length of generated password is 4, you can pass it to the command
#       E.g. passgen 15
#   -------------------------------------------------------------------
# shellcheck disable=SC2046
# shellcheck disable=SC2005
# shellcheck disable=SC2034
# shellcheck disable=SC2086
    passgen () {
    	about 'generates random password from dictionary words'
    	param 'optional integer length'
    	param 'if unset, defaults to 4'
    	example '$ passgen'
    	example '$ passgen 6'
    	group 'base'
      local i pass length=${1:-4}
      pass=$(echo $(for i in $(eval echo "{1..$length}"); do pickfrom /usr/share/dict/words; done))
      echo "With spaces (easier to memorize): $pass"
      echo "Without (use this as the password): $(echo $pass | tr -d ' ')"
    }


#   ---------------------------------------
#   7.  DATE & TIME MANAGEMENT
#   ---------------------------------------


#   ---------------------------------------
#   8.  WEB DEVELOPMENT
#   ---------------------------------------

httpHeaders () { /usr/bin/curl -I -L "$@" ; }             # httpHeaders:      Grabs headers from web page

#   httpDebug:  Download a web page and show info on what took time
#   -------------------------------------------------------------------
    httpDebug () { /usr/bin/curl "$@" -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\\n" ; }




#   ---------------------------------------
#   X.  REMINDERS & NOTES
#   ---------------------------------------

#   remove_disk: spin down unneeded disk
#   ---------------------------------------
#   diskutil eject /dev/disk1s3

#   to change the password on an encrypted disk image:
#   ---------------------------------------
#   hdiutil chpass /path/to/the/diskimage

#   to mount a read-only disk image as read-write:
#   ---------------------------------------
#   hdiutil attach example.dmg -shadow /tmp/example.shadow -noverify

#   mounting a removable drive (of type msdos or hfs)
#   ---------------------------------------
#   mkdir /Volumes/Foo
#   ls /dev/disk*   to find out the device to use in the mount command)
#   mount -t msdos /dev/disk1s1 /Volumes/Foo
#   mount -t hfs /dev/disk1s1 /Volumes/Foo

#   to create a file of a given size: /usr/sbin/mkfile or /usr/bin/hdiutil
#   ---------------------------------------
#   e.g.: mkfile 10m 10MB.dat
#   e.g.: hdiutil create -size 10m 10MB.dmg
#   the above create files that are almost all zeros - if random bytes are desired
#   then use: ~/Dev/Perl/randBytes 1048576 > 10MB.dat
