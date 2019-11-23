# Copyright MIT Licence (c) 2018 Abdoulaye Yatera
# bash_navigator is a tool to jump quickly in your bash navigation history. 
# read the README.md file for more details
# project on github : https://github.com/abdoulayeYATERA/bash_navigator

# it is important to notice that each shell instance will have
# it's own history database (txt files)
# all methods and global varibales names start with "_bash_nav"

cite about-plugin
about-plugin 'bash-navigator is a tool to jump quickly in your bash navigation history using bb and bf commands'

#NAME  
#       bash_navigator is a tool to jump quickly in your bash navigation history  
#       IMPORTANT! Each shell instance has its own navigation history by default.

#ARGUMENTS  
#        -s (--single-nav-hist) : share the same navigation history beetween all your shell instances 

#SYNOPSIS  
#        bb [delta]
#        bbb  
#        bf [delta]  
#        bff  
#        bj [jump_index]  
#        bh  
#        bhelp  

#AVAILABILITY  

#       bash, zsh

#DESCRIPTION  
#       IMPORTANT! Each shell instance has its own navigation history by default.
#        
#        bb          bash back, move back 
#        bbb         bash first, move back to first path 
#        bf          bash forward, move forward 
#        bff         bash last, move forward to last path 
#        bj          bash jump, move specific index path 
#        bh          bash history, show navigation paths history and indexes
#        bhelp       bash help, show help 

#EXAMPLES  
#        bhelp       show bash navigator help page
#        bh          show navigation history and indexes
#        bb          go back in navigation history 
#        bb 4        go back 4 times in navigation history
#        bbb         go to first path in navigation history
#        bf          go forward in navigation history
#        bf 6        go forward 6 times in navigation history
#        bff         go to last path in navigation history
#        bj 78       go to the 78th path in navigation history
#        bj          show navigation history and indexes
#       
#NOTES  
#  
#   Installation:  
#       Put something like this in your $HOME/.bashrc or $HOME/.zshrc:

#              source /path/to/bash_navigator.sh  

#       If you prefer to share the same navigation history beetween all your shell instances: 

#              source /path/to/bash_navigator.sh -s  

#       Restart your shell (zsh/bash), cd around to build up the db.
#       To verify if the db is building up run the bash navigator history command:

#              bh

#        NOW ENJOY, MOVE FASTER!!!

#   Configuration:  
#              IMPORTANT! These  settings  should  go  in  .bashrc/.zshrc BEFORE the above source command.

#              Set $_BASH_NAV_HIST_DB_FOLDER         change the navigation database folder (default /tmp/bash_navigator).
#              Set $_BASH_NAV_HIST_DB_MAX_SIZE       change the number of paths to save in the navigation history (default 100).
#              Set $_BASH_NAVIGATOR_BACK             change bash back command (default bb) 
#              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
#              Set $_BASH_NAVIGATOR_SHOW_HISTORY     change bash history command (default bh) 
#              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
#              Set $_BASH_NAVIGATOR_JUMP             change bash jump command (default bj) 
#              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
#              Set $_BASH_NAVIGATOR_JUMP_TO_FIRST    change bash jump to first command (default bbb) 
#              Set $_BASH_NAVIGATOR_JUMP_TO_LAST     change bash jump to last command (default bff) 

#      Configuration example:  
#              _BASH_NAV_HIST_DB_FOLDER="~/.cache/bash_navigator"
#              _BASH_NAV_HIST_DB_MAX_SIZE=20
#              source /path/to/bash_navigator.sh -s



_bash_nav_default_hist_db_folder="/tmp/bash_navigator"
_bash_nav_default_hist_db_max_size=100
# expand hist db folder if there is a expandable character like '~'
_BASH_NAV_HIST_DB_FOLDER=$(eval echo "$_BASH_NAV_HIST_DB_FOLDER")
#bash nav history database folder
_bash_nav_hist_db_folder="${_BASH_NAV_HIST_DB_FOLDER:-$_bash_nav_default_hist_db_folder}" 
#bash nav history database max size
_bash_nav_hist_db_max_size="${_BASH_NAV_HIST_DB_MAX_SIZE:-$_bash_nav_default_hist_db_max_size}"
## the current index the navigation history
_bash_nav_current_index_nav_hist=1
# when set to 0 the moves are not saved in database
# (use when jumping in navigation history)
_bash_nav_save_next_move_to_nav_hist_db=1
#create a unique file as this bash instance database
_bash_nav_timestamp=$(date +%s)

if [ "$1" = "--single-nav-hist" ] || [ "$0" = "-s" ] ; then
  _bash_nav_db_filename="bash_navigator_database.txt"
else
  _bash_nav_db_filename="bash_navigator_database_${_bash_nav_timestamp}.txt"
fi

_bash_nav_db=${_bash_nav_hist_db_folder}/${_bash_nav_db_filename}
#the current_path
_bash_nav_current_path=""
#create the db directory
[ -d "$_bash_nav_hist_db_folder" ] || {
mkdir -p "$_bash_nav_hist_db_folder"
}

# this method is used to navigate in navigation history
# it will call _bash_nav_delta or _bash_nav_jump to do the navigation
# argument 1: the navigation mode "jump" or "delta"
# "jump": _bash_nav_jump will be used 
# "delta": _bash_nav_delta will be used
_bash_nav() {
  local nav_hist_size
  local nav_mode
  local value
  nav_mode="$1"
  value="$2"
  nav_hist_size=$(_bash_nav_get_nav_hist_size)

  if [ "$nav_mode" = "delta" ]; then
    _bash_nav_delta "$nav_hist_size" "$value" 
  elif [ "$nav_mode" = "jump" ]; then
    _bash_nav_jump "$nav_hist_size" "$value" 
  else 
    echo "unknown navigation mode $1"
  fi
}

# this method must not be called directly, pass by _bash_nav  
# argument 1: the total history size 
# method to jump in bash navigation history
# argument 2: the index in history to move on
# eg $1 = 3 => go to the third path in navigation history
# you can use _bash_nav_show_hist to show navigation history and indexes
_bash_nav_jump() {
  local nav_hist_size
  local index_to_move_on
  nav_hist_size="$1"
  index_to_move_on="$2"
  ## if index to move on is > history size ,then go to last index
  ## else if index to move is < 1 , the go to first index
  if [ "$index_to_move_on" -gt "$nav_hist_size" ]; then
    echo "goind to most recent navigation path"
    index_to_move_on=$nav_hist_size
  elif [ "$index_to_move_on" -lt 1 ]; then
    echo "going to oldest navigation path"
    index_to_move_on=1
  fi
  local path_to_move_on
  path_to_move_on=$(_bash_nav_get_nav_hist_line "$index_to_move_on")
  ##we are moving now in navigation history, so, we doesn't not save this move as a new move in navigation history database
  _bash_nav_save_next_move_to_nav_hist_db=0
  cd "$path_to_move_on"
  # cannot set 
  # _bash_nav_save_next_move_to_nav_hist_db=1
  # here because it will be run before the _bash_nav_precmd
  # so it is in the precmd

  #save new index
  _bash_nav_current_index_nav_hist="$index_to_move_on"
}

# this method must not be called directly, pass by _bash_nav  
# method to move in bash navigation history
# argument 1: the total history size 
# argument 2: the move value
# eg $2 = 3 => go forward 3 times in navigation history
# eg $2 = -7 => go back 7 times in navigation history
# you can use _bash_nav_show_hist to list all navigation history
# (you can see that this function juste calculate 
# the target index from the delta and use the "jump" mode method)
_bash_nav_delta() {
  local delta
  local nav_hist_size
  nav_hist_size="$1"
  delta="$2"
  #check if trying to go to next but already there
  # and check if trying to go to previous but already there
  if [ "$_bash_nav_current_index_nav_hist" -eq "$nav_hist_size" ] && [ "$delta" -gt 0 ]; then
    echo "already on latest path!!"
    return
  elif [ "$_bash_nav_current_index_nav_hist" -eq 1 ] && [ "$delta" -lt 0 ]; then
    echo "already on oldest path!!"
    return
  fi
  ## get the new index to move
  local index_to_move_on
  index_to_move_on=$((_bash_nav_current_index_nav_hist + $delta))
  _bash_nav_jump "$nav_hist_size" "$index_to_move_on"
}


# precmd function
# this method will be called after each command, just before prompt
# see https://github.com/rcaloras/bash-preexec for more details
# add current line to nav history databae (txt file)
# however if the last and new navigation history paths are the same, do nothing
_bash_nav_precmd() {
  local new_path
  new_path="$(command pwd)"
  #this method is called on every executed commands
  #so,we check if the executed command changed the path
  if [ "$_bash_nav_current_path" = "$new_path" ]; then
    # if not, do nothing 
    return 
  fi
  #the path has changed
  # save the new current path
  _bash_nav_current_path="$new_path"
  ## check if this move must be save in database a new move
  if [ "$_bash_nav_save_next_move_to_nav_hist_db" -ne 1 ]; then 
    # not save this move as a new move
    # enable saving for the next move
    _bash_nav_save_next_move_to_nav_hist_db=1
    return
  fi
  local most_recent_path_in_hist
  most_recent_path_in_hist="$(_bash_nav_get_last_nav_hist_line)"
  # if new path and most recent path in navigation history are the same
  # do nothing to navigation history
  # eg: after a move back "bb" and cd to where we were
  if [ "$new_path" = "$most_recent_path_in_hist" ]; then
    #update navigation index to most recent
    local nav_hist_size
    nav_hist_size="$(_bash_nav_get_nav_hist_size)" 
    _bash_nav_current_index_nav_hist="$nav_hist_size"
    return
  fi
  # add new path to database
  _bash_nav_add_to_hist "$new_path"
}

# use to go back in navigation history
# argmuent 1: the delta (alway positive)
# eg: $1 = 4 will call _bash_nav -4
# if no argument delta is set to 1 => go back one time
_bash_nav_hist_back() {
  #by default if no argument, go to previous navigation history path
  local back_value
  local nav_type="delta"
  back_value=1
  if [ ! -z "$1" ];  then
    back_value="$1"
  fi
  _bash_nav "$nav_type" "$((0 - back_value))"
}

# use to go forward in navigation history
# argmuent 1: the delta (alway positive)
# eg: 2 will call _bash_nav 2
# if no argument, delta is set to 1 => go forward one time
_bash_nav_hist_forward() {
  #by default if no argument, go to next navigation history path
  local forward_value
  local nav_type="delta"
  forward_value=1
  if [ ! -z "$1" ];  then
    forward_value="$1"
  fi
  _bash_nav "$nav_type" "$forward_value"
}

# use to jump to navigation history
# argument 1: the jump target index in the navigation history database
# if no argument, show navigation history and indexes
_bash_nav_hist_jump() {
  local jump_index="$1"
  local nav_type="jump"
  if [ -z "$jump_index" ]; then  
    #show hist
    _bash_nav_show_hist 
    echo "jump index argument missing! select one from above"
    echo "eg: bj 3"
    return
  fi
  _bash_nav "jump" "$jump_index"
}

# jump to last (newest) path in navigation history
_bash_nav_hist_jump_to_last() {
  local jump_index
  jump_index=$(_bash_nav_get_nav_hist_size)
  _bash_nav "jump" "$jump_index"
}

# jump to first (oldest) path in navigatio history
_bash_nav_hist_jump_to_first() {
  _bash_nav "jump" 1
}

# get the last line of a file
# argument 1: the file path
_bash_nav_get_file_last_line() {
  tail -1 "$1" 2> /dev/null
}

# get a specific line of a file
# argument 1: le line number of the line to get
# (first line is 1)
# argument 2: the file path
_bash_nav_get_file_line() {
  sed -n "$2"p "$1"
}

# get the last line of the bash navigation history
# the most recent path in navigation history
_bash_nav_get_last_nav_hist_line() {
  _bash_nav_get_file_last_line "$_bash_nav_db"
}

# get a specific line of the bash navigation history
_bash_nav_get_nav_hist_line() {
  _bash_nav_get_file_line "$_bash_nav_db" "$1"
}

# return the number of line in a file
# argument 1: the file path
_bash_nav_get_file_line_count() {
  cat "$1" | wc -l
}

# return the number of line in navigation history database
_bash_nav_get_nav_hist_size() {
  _bash_nav_get_file_line_count "$_bash_nav_db"
}

# show navigation history 
# an * is added to show where we are in the navigation history
_bash_nav_show_hist() {
  cat -n "$_bash_nav_db" | sed "${_bash_nav_current_index_nav_hist}s/^/*/"
}

# show help page 
_bash_nav_hist_help() {
   echo "$_bash_nav_help_text" | "$PAGER"
}

# add a path to navigation history database and update current index
# if navigation history exceed the max size, reduce it to max size by removing oldest paths
_bash_nav_add_to_hist() {
  local path_to_add
  path_to_add="$1"
  _bash_nav_append_to_file "$path_to_add" "$_bash_nav_db"
  #update index to the last one in navigation history
  _bash_nav_current_index_nav_hist="$(_bash_nav_get_nav_hist_size)"
  # if the navigation history exceed the max size, reduce it to max size by removing oldest paths 
  if [ "$_bash_nav_current_index_nav_hist" -gt "$_bash_nav_hist_db_max_size" ]; then
      local rezised_bash_nav_db=$(tail -n "$_bash_nav_hist_db_max_size" "$_bash_nav_db")
      _bash_nav_write_file "$rezised_bash_nav_db" "$_bash_nav_db"
      _bash_nav_current_index_nav_hist="$_bash_nav_hist_db_max_size"
  fi
}

# append text to file
# file hierarchy is created if not exists
# argument 1: text to append
# argument 2: destination file
_bash_nav_append_to_file() {
  local text_to_append
  local file
  local file_dir
  text_to_append="$1"
  file="$2"
  file_dir=$(dirname "$file")
  mkdir -p "$file_dir"
  echo "$text_to_append" >> "$file"
}

# write text in file
# the file is replaced if exists
# file hierarchy is created if not exists
# argument 1: text to write
# argument 2: destination file
_bash_nav_write_file() {
  local text_to_write
  local file
  local file_dir
  text_to_write="$1"
  file="$2"
  file_dir=$(dirname "$file")
  mkdir -p "$file_dir"
  echo "$text_to_write" > "$file"
}

# set aliases
alias ${_BASH_NAVIGATOR_BACK:-bb}='_bash_nav_hist_back 2>&1'
alias ${_BASH_NAVIGATOR_FORWARD:-bf}='_bash_nav_hist_forward 2>&1'
alias ${_BASH_NAVIGATOR_SHOW_HISTORY:-bh}='_bash_nav_show_hist 2>&1'
alias ${_BASH_NAVIGATOR_JUMP:-bj}='_bash_nav_hist_jump 2>&1'
alias ${_BASH_NAVIGATOR_JUMP_TO_FIRST:-bbb}='_bash_nav_hist_jump_to_first 2>&1'
alias ${_BASH_NAVIGATOR_JUMP_TO_LAST:-bff}='_bash_nav_hist_jump_to_last 2>&1'
alias ${_BASH_NAVIGATOR_HELP:-bhelp}='_bash_nav_hist_help 2>&1'

# add the method _bash_nav_precmd to precmd functions
# see https://github.com/rcaloras/bash-preexec for more details on precmd functions
if type compctl >/dev/null 2>&1; then
  # zsh
  [[ -n "${precmd_functions[(r)_bash_nav_precmd]}" ]] || {
  precmd_functions[$(($#precmd_functions+1))]=_bash_nav_precmd
}
 elif type complete >/dev/null 2>&1; then
   # bash
   grep "_bash_nav_precmd" <<< "$PROMPT_COMMAND" >/dev/null || {
   PROMPT_COMMAND="$PROMPT_COMMAND"$'\n'"_bash_nav_precmd 2>/dev/null;"
 }
fi

# bhelp text
_bash_nav_help_text='
NAME  
       bash_navigator is a tool to jump quickly in your bash navigation history
       IMPORTANT! Each shell instance has its own navigation history by default.

ARGUMENTS
        -s (--single-nav-hist) : share the same navigation history beetween all your shell instances 

SYNOPSIS  
        bb [delta]
        bbb  
        bf [delta]  
        bff  
        bj [jump_index]  
        bh  
        bhelp  

AVAILABILITY  

       bash, zsh

DESCRIPTION  
       IMPORTANT! Each shell instance has its own navigation history by default.
        
        bb          bash back, move back 
        bbb         bash first, move back to first path 
        bf          bash forward, move forward 
        bff         bash last, move forward to last path 
        bj          bash jump, move specific index path 
        bh          bash history, show navigation paths history and indexes
        bhelp       bash help, show help 

EXAMPLES  
        bhelp       show bash navigator help page
        bh          show navigation history and indexes
        bb          go back in navigation history 
        bb 4        go back 4 times in navigation history
        bbb         go to first path in navigation history
        bf          go forward in navigation history
        bf 6        go forward 6 times in navigation history
        bff         go to last path in navigation history
        bj 78       go to the 78th path in navigation history
        bj          show navigation history and indexes
       
NOTES  
  
   Installation:  
       Put something like this in your $HOME/.bashrc or $HOME/.zshrc:

              source /path/to/bash_navigator.sh

       If you prefer to share the same navigation history beetween all your shell instances: 

              source /path/to/bash_navigator.sh -s

       Restart your shell (zsh/bash), cd around to build up the db.
       To verify if the db is building up run the bash navigator history command:

              bh

        NOW ENJOY, MOVE FASTER!!!

   Configuration:  
              IMPORTANT! These  settings  should  go  in  .bashrc/.zshrc BEFORE the above source command.

              Set $_BASH_NAV_HIST_DB_FOLDER         change the navigation database folder (default /tmp/bash_navigator).
              Set $_BASH_NAV_HIST_DB_MAX_SIZE       change the number of paths to save in the navigation history (default 100).
              Set $_BASH_NAVIGATOR_BACK             change bash back command (default bb) 
              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
              Set $_BASH_NAVIGATOR_SHOW_HISTORY     change bash history command (default bh) 
              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
              Set $_BASH_NAVIGATOR_JUMP             change bash jump command (default bj) 
              Set $_BASH_NAVIGATOR_FORWARD          change bash forward command (default bf) 
              Set $_BASH_NAVIGATOR_JUMP_TO_FIRST    change bash jump to first command (default bbb) 
              Set $_BASH_NAVIGATOR_JUMP_TO_LAST     change bash jump to last command (default bff) 

      Configuration example:  
              _BASH_NAV_HIST_DB_FOLDER="~/.cache/bash_navigator"
              _BASH_NAV_HIST_DB_MAX_SIZE=20
              source /path/to/bash_navigator.sh -s
  
PROJECT  
      https://github.com/abdoulayeYATERA/bash_navigator
'

