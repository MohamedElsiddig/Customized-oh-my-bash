#!/bin/bash
################################################################################
#          FILE:  fastfile.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Michael Varner (musikmichael@web.de)
#       VERSION:  1.0.0
#
# This plugin adds the ability to on the fly generate and access file shortcuts.
#
################################################################################
cite about-plugin about
about-plugin 'This plugin adds the ability to on the fly generate and access file shortcuts.'

###########################
# Settings 

# These can be overwritten any time.
# If they are not set yet, they will be
# overwritten with their default values

default fastfile_dir        "${HOME}/.fastfile/"
default fastfile_var_prefix ""

###########################
# Impl

#
# Generate a shortcut
#
# Arguments:
#    1. name - The name of the shortcut (default: name of the file)
#    2. file - The file or directory to make the shortcut for
# STDOUT:
#    => fastfle_print
#
function fastfile() {
	about 'This plugin adds the ability to on the fly generate and access file shortcuts.'
	group 'misc'
	if [[ -f $2 ]]
		then
    	file=$(readlink -f "$2")
    else
    	file=$(readlink -f ".")
  fi
        
  if [[ -z $1 ]]
    then
    	name=$(echo "$(basename "$file")" | tr " " "_")
    else
    	test "$1" || $1="$(basename "$file")"
    	name=$(echo "$1" | tr " " "_")
	fi

  mkdir -p "${fastfile_dir}"
  echo "$file" > "$(fastfile_resolv "$name")"

  fastfile_sync
  fastfile_print "$name"
}

#
# Resolve the location of a shortcut file (the database file, where the value is written!)
#
# Arguments:
#    1. name - The name of the shortcut
# STDOUT:
#   The path
#
function fastfile_resolv() {
    echo "${fastfile_dir}${1}"
}

#
# Get the real path of a shortcut
#
# Arguments:
#    1. name - The name of the shortcut
# STDOUT:
#    The path
#
function fastfile_get() {

		cat "$(fastfile_resolv "$1")"
}

#
# Print a shortcut
#
# Arguments:
#    1. name - The name of the shortcut
# STDOUT:
#    Name and value of the shortcut
#
function fastfile_print() {
    echo "${fastfile_var_prefix}${1} -> $(fastfile_get "$1")"
}

#
# List all shortcuts
#
# STDOUT:
#    (=> fastfle_print) for each shortcut
#
function fastfile_ls() {
    for f in "${fastfile_dir}"/*; do 
	file=`basename "$f"` # To enable simpler handeling of spaces in file names
	varkey=`echo "$file" | tr " " "_"`

	# Special format for colums
	echo "${fastfile_var_prefix}${varkey}|->|$(fastfile_get "$file")"
    done | column -t -s "|"
}

#
# Remove a shortcut
#
# Arguments:
#    1. name - The name of the shortcut (default: name of the file)
#    2. file - The file or directory to make the shortcut for
# STDOUT:
#    => fastfle_print
#
function fastfile_rm() {
    fastfile_print "$1"
    rm "$(fastfile_resolv "$1")"
}

#
# Generate the aliases for the shortcuts
#
function fastfile_sync() {
    for f in "${fastfile_dir}"/*; do 
	file=`basename "$f"` # To enable simpler handeling of spaces in file names
	varkey=`echo "$file" | tr " " "_"`

	alias "${fastfile_var_prefix}${varkey}"=\'"$(fastfile_get "$file")"\'
    done
}

##################################
# Shortcuts

alias ff=fastfile
alias ffp=fastfile_print
alias ffrm=fastfile_rm
alias ffls=fastfile_ls
alias ffsync=fastfile_sync
######################################


#Automatically enable fastfile completion

# _OSH-component-item-is-enabled completion fastfile

# if [[ "$?" != "0" ]] && [[ "${AUTO_ENABLING}" == "enable" ]]
# 	then
# 		source "${OSH}/themes/colours.theme.sh"
# 		source "${OSH}/themes/base.theme.sh"
# 		echo ""
# 		echo -e "$echo_bold_green Enabling fastfile plugin completion${echo_normal}"
# 		sleep 1
# 		_enable-completion fastfile

# fi

##################################
# Init 
for short in "${fastfile_dir}"/*
do
if [[ -f "${short}" ]]
	then
		fastfile_sync
fi
done

