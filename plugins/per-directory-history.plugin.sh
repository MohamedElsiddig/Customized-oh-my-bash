cite about-plugin
about-plugin 'An implementation of per directory history for bash'

export HISTTIMEFORMAT="%h/%d - %H:%M:%S "
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000000
export HISTFILESIZE=1000000
shopt -s histappend ## append, no clearouts                                                               
shopt -s histverify ## edit a recalled history line before executing                                      
shopt -s histreedit ## reedit a history substitution line if it failed  
      


[[ -z $HISTORY_BASE ]] && HISTORY_BASE="$PWD/.dir_bash_history"
#_per_directory_history_directory="$HISTORY_BASE${PWD:A}/history"

function per-directory-history-toggle-history() {
  if [[ $_per_directory_history_is_global == true ]]; then
    _per-directory-history-set-directory-history
    echo -e "\nusing local history"
  else
    _per-directory-history-set-global-history
    echo -e "\nusing global history"
  fi

}


#function per-dir_bash_history()
#{
##    #if this directory is writable then write to directory-based history file
##    #otherwise write history in the usual home-based history file                    
##    tmpDir=$PWD
##    #echo "#"`date '+%s'` >> $HISTFILE
##    #echo $USER' has exited '$PWD' for '$@ >> $HISTFILE
#    #cd "$@" # do actual cd
#    if [ -w $PWD ]; then export HISTFILE="$PWD/.dir_bash_history"; touch $HISTFILE; chmod --silent 777 $HISTFILE;
#    else export HISTFILE="$HOME/.bash_history";
#    fi
##    #echo "#"`date '+%s'` >> $HISTFILE
##    #echo $USER' has entered '$PWD' from '$OLDPWD >> $HISTFILE

#}
#alias cd="per-dir_bash_history"
#initial shell opened                                                                                     

#timestamp all history entries                                                                            
                            
function _per-directory-history-set-directory-history() {
  #if [[ $_per_directory_history_is_global == true ]]; then
     if [[ -w $PWD ]]; then export HISTFILE="$PWD/.dir_bash_history"; touch $HISTFILE; chmod --silent 777 $HISTFILE;
    else export HISTFILE="$HOME/.bash_history";
    fi
  #fi
  _per_directory_history_is_global=false
}
function _per-directory-history-set-global-history() {
  if [[ $_per_directory_history_is_global == false ]]; then
    HISTFILE=$HISTFILE
    local original_histsize=$HISTSIZE
    HISTSIZE=0
    HISTSIZE=$original_histsize
    if [[ -e "$HISTFILE" ]]; then
        export HISTFILE="$HOME/.bash_history";
    fi
  fi
  _per_directory_history_is_global=true
}
CHPWD_COMMAND="${CHPWD_COMMAND:+$CHPWD_COMMAND;}_per-directory-history-set-directory-history"
## Save the history after each command finishes                                                           
## (and keep any existing PROMPT_COMMAND settings)                   
export PROMPT_COMMAND="history -a; history -c; history -r;$PROMPT_COMMAND"                                      
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
bind -x '"\C-g": "per-directory-history-toggle-history"'

