# System clipboard integration
cite about-plugin
about-plugin 'Plugin support for doing system clipboard copy and paste operations from the command line'
# This file has support for doing system clipboard copy and paste operations
# from the command line in a generic cross-platform fashion.
#
# On OS X and Windows, the main system clipboard or "pasteboard" is used. On other
# Unix-like OSes, this considers the X Windows CLIPBOARD selection to be the
# "system clipboard", and the X Windows `xclip` command must be installed.

# clipcopy - Copy data to clipboard
#
# Usage:
#
#  <command> | clipcopy    - copies stdin to clipboard
#
#  clipcopy <file>         - copies a file's contents to clipboard
#
function clipcopy() {
	about 'clipcopy - Copy data to clipboard'
	group 'misc'
	param '1: File name or command output'
	example '<command> | clipcopy    - copies stdin to clipboard'
	example "clipcopy <file>         - copies a file's contents to clipboard"
	
  local file=$1
  if [[ $OSTYPE == darwin* ]]; then
    if [[ -z $file ]]; then
      pbcopy
    else
      cat $file | pbcopy
    fi
  elif [[ $OSTYPE == cygwin* ]]; then
    if [[ -z $file ]]; then
      cat > /dev/clipboard
    else
      cat $file > /dev/clipboard
    fi
  else
    if [[ `which xclip` ]]; then
      if [[ -z $file ]]; then
        xclip -in -selection clipboard
      else
        xclip -in -selection clipboard $file
      fi
   elif [[ `which xsel` ]]; then
      if [[ -z $file ]]; then
        xsel --clipboard --input 
      else
        cat "$file" | xsel --clipboard --input
      fi
    else
      print "clipcopy: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
      return 1
    fi
  fi
 
}

# clippaste - "Paste" data from clipboard to stdout
#
# Usage:
#
#   clippaste   - writes clipboard's contents to stdout
#
#   clippaste | <command>    - pastes contents and pipes it to another process
#
#   clippaste > <file>      - paste contents to a file
#
# Examples:
#
#   # Pipe to another process
#   clippaste | grep foo
#
#   # Paste to a file
#   clippaste > file.txt
function clippaste() {
	about "clippaste   - writes clipboard's contents to stdout"
	group 'misc'
	param '1: File name or as a command input'
	example ' clippaste | <command>   - pastes contents and pipes it to another process'
	example "clippaste > <file>    - paste contents to a file"
  if [[ $OSTYPE == darwin* ]]; then
    pbpaste
  elif [[ $OSTYPE == cygwin* ]]; then
    cat /dev/clipboard
  else
    if [[ `which xclip` ]]; then
      xclip -out -selection clipboard
    elif [[ `which xsel` ]]; then
      xsel --clipboard --output
    else
      print "clipcopy: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
      return 1
    fi
  fi
}
