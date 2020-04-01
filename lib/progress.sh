#!/usr/bin/env bash

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences
# CSI n K | EL – Erase in Line | If n is 2, clear entire line. Cursor position does not change.
# Also move cursor to the beginning of line with the '\r'.
CLEAR_LINE='\x1b[2K\r'

# from https://en.wikipedia.org/wiki/ANSI_escape_code#Example_of_use_in_shell_scripting
#HIGHLIGHT_REVERSE_VIDEO='\x1b[7m'
#HIGHLIGHT_YELLOW_AND_RED='\x1b[93;41m'
#HIGHLIGHT_RESET='\x1b[0m'

print_doing() {
	printf "☐ doing '%s'..." "${1}"
}

print_done() {
	printf "${echo_bold_green}${CLEAR_LINE}[✔] ${echo_normal}'%s' ${echo_bold_green}done${echo_normal}\\n" "${1}"
}

# special exit code
SKIPPED=255

print_not_done() {
	if [ "${2}" -eq ${SKIPPED} ]
	then
		printf "${echo_bold_white}${CLEAR_LINE}[ ] ${echo_normal}'%s' ${echo_bold_white}skipped${echo_normal}\\n" "${1}"
	else
		printf "${echo_bold_red}${CLEAR_LINE}[✘] ${echo_normal}'%s' ${echo_bold_red}failed${echo_normal}\\n" "${1}"
	fi
}
