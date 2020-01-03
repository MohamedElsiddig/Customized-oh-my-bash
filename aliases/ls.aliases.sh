#!/usr/bin/env bash
#  ---------------------------------------------------------------------------
cite about-alias
about-alias 'This file holds all ls command aliases'
# Directory Listing aliases
if [[ `command -v lsic` ]]
	then
		alias ls='lsic'
		alias dir='lsic -hFx'
		alias l.='lsic -d .* --color=auto' # short listing, only hidden files - .*
		alias l='lsic -lathF --color=auto'             # long, sort by newest to oldest
		alias L='lsic -latrhF --color=auto'            # long, sort by oldest to newest
		alias la='lsic -Al --color=auto'               # show hidden files
		#alias lc='ls -lcr --color=auto'              # sort by change time
		alias lk='lsic -lSr --color=auto'              # sort by size
		alias lh='lsic -lSrh --color=auto'             # sort by size human readable
		alias lm='lsic -al --color=auto | more'        # pipe through 'more'
		alias lo='lsic -laSFh --color=auto'            # sort by size largest to smallest
		alias lr='lsic -lR --color=auto'               # recursive ls
		alias lt='lsic -ltr --color=auto'              # sort by date
		alias lu='lsic -lur --color=auto'              # sort by access time
		alias ls='lsic --color=auto'
		alias ll='lsic -alF --color=auto'
		alias la='lsic -A --color=auto'
		#alias l='ls -CF --color=auto'
	else
		alias dir='ls -hFx'
		alias l.='ls -d .* --color=auto' # short listing, only hidden files - .*
		alias l='ls -lathF --color=auto'             # long, sort by newest to oldest
		alias L='ls -latrhF --color=auto'            # long, sort by oldest to newest
		alias la='ls -Al --color=auto'               # show hidden files
		#alias lc='ls -lcr --color=auto'              # sort by change time
		alias lk='ls -lSr --color=auto'              # sort by size
		alias lh='ls -lSrh --color=auto'             # sort by size human readable
		alias lm='ls -al --color=auto | more'        # pipe through 'more'
		alias lo='ls -laSFh --color=auto'            # sort by size largest to smallest
		alias lr='ls -lR --color=auto'               # recursive ls
		alias lt='ls -ltr --color=auto'              # sort by date
		alias lu='ls -lur --color=auto'              # sort by access time
		alias ls='ls --color=auto'
		alias ll='ls -alF --color=auto'
		alias la='ls -A --color=auto'
		#alias l='ls -CF --color=auto'
fi

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

alias dud='du -d 1 -h'                      # Short and human-readable file listing
alias duf='du -sh *'                        # Short and human-readable directory listing
