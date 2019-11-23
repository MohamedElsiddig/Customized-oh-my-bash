#!/usr/bin/env bash
## source: https://github.com/kdabir/has
cite about-plugin
about-plugin 'Checks presence of various command line tools and their versions on the path'
## Important so that version is not extracted for failed commands (not found)
set -o pipefail

 BINARY_NAME="has"
 VERSION="v1.4.0"
 #HAS_ALLOW_UNSAFE=y
## constant - symbols for success failure
 txtreset="$(tput sgr0)"
 txtbold="$(tput bold)"
 txtblack="$(tput setaf 0)"
 txtred="$(tput setaf 1)"
 txtgreen="$(tput setaf 2)"
 txtyellow="$(tput setaf 3)"
 txtblue="$(tput setaf 4)"
 txtpurple="$(tput setaf 5)"
 txtcyan="$(tput setaf 6)"
 txtwhite="$(tput setaf 7)"
# unicode "✗"
 fancyx=' \342\234\227'
# unicode "✓"
 checkmark=' \342\234\223'
 PASS="\e[1m\e[32;1m ✔\e[m"
# FAIL="\e[1m\e[38;5;1m ✘\e[m"
 #PASS="${txtbold}${txtgreen}${checkmark}${txtreset}"
 FAIL="${txtbold}${txtred}${fancyx}${txtreset}"

## These variables are used to keep track of passed and failed commands
OK=0
KO=0

## Regex to extract simple version - extracts numeric sem-ver style versions
REGEX_SIMPLE_VERSION="([[:digit:]]+\.?){2,3}"

## RC file can contain commands to be tested
RC_FILE=".hasrc"

# try to extract version by executing "${1}" with "${2}" arg
__dynamic_detect(){
  cmd="${1}"
  params="${2}"
  version=$( eval "${cmd}" "${params}" "2>&1" | grep -Eo "${REGEX_SIMPLE_VERSION}" | head -1)
  status=$?
}

# commands that use `--version` flag
__dynamic_detect--version(){
  __dynamic_detect "${1}" "--version"
}

# commands that use `-version` flag
__dynamic_detect-version(){
  __dynamic_detect "${1}" "-version"
}

# commands that use `-v` flag
__dynamic_detect-v(){
  __dynamic_detect "${1}" "-v"
}

# commands that use `-V` flag
__dynamic_detect-V(){
  __dynamic_detect "${1}" "-V"
}

# commands that use `version` argument
__dynamic_detect-arg_version(){
  __dynamic_detect "${1}" "version"
}

## the main function
__detect(){
  name="${1}"

  # setup aliases - maps commonly used name to exact command name
  case ${name} in
    golang                ) command="go"            ;;
    jre                   ) command="java"          ;;
    jdk                   ) command="javac"         ;;
    nodejs                ) command="node"          ;;
    goreplay              ) command="gor"           ;;
    httpie                ) command="http"          ;;
    homebrew              ) command="brew"          ;;
    awsebcli              ) command="eb"            ;;
    awscli                ) command="aws"           ;;
    aria2                ) command="aria2c"           ;;
    *coreutils|linux*utils) command="gnu_coreutils" ;;
    *                     ) command=${name}         ;;
  esac

  case "${command}" in

    # commands that need --version flag
    bash|zsh)               __dynamic_detect--version "${command}" ;;
    git|hg|svn|bzr|man)         __dynamic_detect--version "${command}" ;;
    gcc|make|g++)               __dynamic_detect--version "${command}" ;;
    curl|wget|http|ufw|samba|tldr|aria2c)         __dynamic_detect--version "${command}" ;;
    vim|emacs|nano|subl|pip|pip3)    __dynamic_detect--version "${command}" ;;
    bats|tree|ack|autojump|bat) __dynamic_detect--version "${command}" ;;
    jq|ag|brew)             __dynamic_detect--version "${command}" ;;
    apt|apt-get|aptitude|apt-cache|dpkg|apt-offline)   __dynamic_detect--version "${command}" ;;
    sed|awk|grep|file|sudo|find|less|cat|tree) __dynamic_detect--version "${command}" ;;
    gzip|xz|unar|bzip2|msfconsole)     __dynamic_detect--version "${command}" ;;
    tar|pv|wine|ls|fzf)                 __dynamic_detect--version "${command}" ;;

    R)                      __dynamic_detect--version "${command}" ;;
    node|npm|yarn)          __dynamic_detect--version "${command}" ;;
    grunt|brunch)           __dynamic_detect--version "${command}" ;;
    ruby|gem|rake|bundle|cmake|systemctl|systemd)   __dynamic_detect--version "${command}" ;;
    python|python3)         __dynamic_detect--version "${command}" ;;
    perl|perl6|php|php5|tor)    __dynamic_detect--version "${command}" ;;
    groovy|gradle|mvn)      __dynamic_detect--version "${command}" ;;
    lein)                   __dynamic_detect--version "${command}" ;;
    aws|eb|sls|gcloud)      __dynamic_detect--version "${command}" ;;

    # commands that need -v flag
    unzip|apache2|figlet)                  __dynamic_detect-v "${command}" ;;

    # commands that need -V flag
    ab|clear|ssh)                     __dynamic_detect-V "${command}" ;;

    # commands that need -version flag
    ant|java|javac)         __dynamic_detect-version "${command}" ;;
    scala|kotlin)           __dynamic_detect-version "${command}" ;;

    # commands that need version arg
    go|hugo)                __dynamic_detect-arg_version "${command}" ;;

    ## Example of commands that need custom processing

    ## TODO cleanup, currently need to add extra space in regex, otherwise the time gets selected
    gulp)
      version=$( gulp --version 2>&1| grep -Eo " ${REGEX_SIMPLE_VERSION}" | head -1)
      status=$?
      ;;

    ## gor returns version but does not return normal status code, hence needs custom processing
    gor)
      version=$( gor version 2>&1 | grep -Eo "${REGEX_SIMPLE_VERSION}" | head -1)
      if [ $? -eq 1 ]; then status=0; else status=1; fi
      ;;

    sbt)
      version=$( sbt about 2>&1 | grep -Eo "([[:digit:]]{1,4}\.){2}[[:digit:]]{1,4}" | head -1)
      status=$?
      ;;

    ## use 'readlink' to test for GNU coreutils
    # readlink (GNU coreutils) 8.28
    gnu_coreutils)    __dynamic_detect--version readlink ;;

    ## hub uses --version but version string is on second line, or third if HUB_VERBOSE set
    hub)
      version=$( HUB_VERBOSE='' hub --version 2>&1 | sed -n 2p | grep -Eo "${REGEX_SIMPLE_VERSION}" | head -1)
      status=$?
      ;;

    ## zip uses -v but version string is on second line
    zip)
      version=$( zip -v 2>&1 | sed -n 2p | grep -Eo "${REGEX_SIMPLE_VERSION}" | head -1)
      status=$?
      ;;

    has)
      version=$( has -v 2>&1 | grep -Eo "${REGEX_SIMPLE_VERSION}" | head -1)
      status=$?
      ;;

    *)
      ## Can allow dynamic checking here, i.e. checking commands that are not listed above
      if [[ "${HAS_ALLOW_UNSAFE}" == "y" ]]; then
        __dynamic_detect--version "${command}"
        ## fallback checking based on status!=127 (127 means command not found)
        ## TODO can check other type of supported version-checks if status was not 127
      else
        ## -1 is special way to tell command is not supported/whitelisted by `has`
        status="-1"
      fi
      ;;
  esac

  if [ "$status" -eq "-1" ]; then     ## When unsafe processing is not allowed, the -1 signifies
    printf '%b %s not understood by has\n' "${FAIL}" "${command}"
    KO=$(( KO+1 ))

  elif [ ${status} -eq 127 ]; then    ## command not installed
    printf '%b %s\n' "${FAIL}" "${command}"
    #if [[ -x /usr/lib/command-not-found ]] ; then
     #           /usr/lib/command-not-found --no-failure-msg -- ${command+"$command"} && :
    #fi
    KO=$(( KO+1 ))

  elif [ ${status} -eq 0 ] || [ ${status} -eq 141 ]; then      ## successfully executed
    printf "%b %s %b\n" "${PASS}" "${command}" "${txtbold}${txtyellow}${version}${txtreset}"
    OK=$(( OK+1 ))

  else  ## as long as its not 127, command is there, but we might not have been able to extract version
    printf '%b %s\n' "${PASS}" "${command}"
    OK=$(( OK+1 ))
  fi
} #end __detect

if [ -s "${RC_FILE}" ];  then
  HASRC="true"
fi

has (){
	about 'Checks presence of various command line tools and their versions on the path'
	group 'misc'
	param "1: Command name or group of commands"
	example "$ has git curl node"
# if HASRC is not set AND no arguments passed to script
if [[ -z "${HASRC}" ]] && [ "$#" -eq 0 ]; then
  # print help
  reference has
elif [[ $1 == "-v" || $1 == "-V" || $1 == "--version" ]];then
  echo $VERSION
else
  # for each cli-arg
  for cmd in "$@"; do
    __detect "${cmd}"
  done

  ## display found / total
  #  echo  ${OK} / $(($OK+$KO))

  ## if HASRC has been set
  if [[ -n "${HASRC}" ]]; then
    ## for all
    while read -r line; do
      __detect "${line}"
    done <<<"$( grep -Ev "^\s*(#|$)" "${RC_FILE}" )"
  fi

  ## max status code that can be returned
  MAX_STATUS_CODE=126

  if [[ "${KO}" -gt "${MAX_STATUS_CODE}" ]]; then
    exit "${MAX_STATUS_CODE}"
  else
    return "${KO}"
    :
  fi

fi

}
