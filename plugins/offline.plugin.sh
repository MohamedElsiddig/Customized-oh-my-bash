#!/usr/bin/env bash
#############################
#
# https://github.com/srijanshetty/offline
#
#############################

cite about-plugin
about-plugin 'Store commands when offline and execute them later in batch mode'

function offline (){
COMMAND_NAME="offline"
STORED_COMMANDS="${HOME}/.${COMMAND_NAME}.commands"
TEMP_FILE="/tmp/${COMMAND_NAME}.tmp"

function _offline-help() {
cat << _EOH_
USAGE: offline <command> [arguments]

COMMAND:

    -l | list            List all the offline commands
    -x | execute         Execute all offline comands
    -r | remove          Clean the offline script
    -h | help            Show this help message

_EOH_
}

function _offline-list() {
   if [[ -e "$STORED_COMMANDS" ]]
		then
			 cat "$STORED_COMMANDS"
		else
			:
	fi
}

function _offline-remove() {
	if [[ -e "$STORED_COMMANDS" ]] 
	 	then
			 rm "$STORED_COMMANDS"
		else
			:
	fi

}

# Run all the commands in the given file
function _offline-execute() {
    # Exit if there are no commands to execute
    [[ -e "$STORED_COMMANDS" ]] || return 0

    # Make a copy in the temp folder
    cp "$STORED_COMMANDS" "$TEMP_FILE" && rm -f "$STORED_COMMANDS" && touch "$STORED_COMMANDS"

    # Now run each command one by one
    while read line; do
        echo "$line" | sed 's|cd ||' | tr '\n' ':'; echo -en '\n'
        eval "$line" || echo "$line" >> "$STORED_COMMANDS"
    done < "$TEMP_FILE"

    # Delete the tmp file
    rm -f "$TEMP_FILE"
}

# Append the offline command to a log
function _offline-store() {
    # Check if the file exists or not
    [ -e "$STORED_COMMANDS" ] || touch "$STORED_COMMANDS"

    # Append the command to the file
    echo "cd \"$PWD\" && $*" >> "$STORED_COMMANDS"
}

# Parse the arguments
case "$1" in
    help|-h|--help)                         _offline-help;;
    list|-l|--list|--ls)                    _offline-list;;
    remove|-r|--remove|--rm)                _offline-remove;;
    execute|-x|--execute)                   _offline-execute;;
    *) 
		if [[ -n $@ ]]
			then   
 		           _offline-store "$*"
			else
				_offline-help
		fi ;;
esac
}
