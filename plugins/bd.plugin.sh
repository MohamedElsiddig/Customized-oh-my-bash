#! /bin/bash
cite about-plugin
about-plugin 'Quickly go back to a specific parent directory in bash instead of typing "cd ../../.." redundantly.'
usage_error () {
  cat << EOF
------------------------------------------------------------------
Name: bd
Version: 1.02

------------------------------------------------------------------
Description: Go back to a specified directory up in the hierarchy.

------------------------------------------------------------------
How to use:

Please refer https://github.com/vigneshwaranr/bd

EOF
}

newpwd() {
  oldpwd=$1
  case "$2" in
    -s)
      pattern=$3
      NEWPWD=$(echo $oldpwd | sed 's|\(.*/'$pattern'[^/]*/\).*|\1|')
      ;;
    -si)
      pattern=$3
      NEWPWD=$(echo $oldpwd | perl -pe 's|(.*/'$pattern'[^/]*/).*|$1|i')
      ;;
    *)
      pattern=$2
      NEWPWD=$(echo $oldpwd | sed 's|\(.*/'$pattern'/\).*|\1|')
  esac
}
bd () {
if [ $# -eq 0 ]
then
  usage_error
elif [ "${@: -1}" = -v ]
then
  usage_error
else
  oldpwd=$(pwd)

  newpwd "$oldpwd" "$@"
  
  if [ "$NEWPWD" = "$oldpwd" ]
  then
    echo "No such occurrence."
  else
    echo $NEWPWD
    cd "$NEWPWD"
  fi
  unset NEWPWD
fi
}
