# create a PROPMT_COMMAND equivalent to store chpwd functions
typeset -g CHPWD_COMMAND=""

_chpwd_hook() {
  shopt -s nullglob

  local f

  # run commands in CHPWD_COMMAND variable on dir change
  if [[ "$PREVPWD" != "$PWD" ]]; then
    local IFS=$';'
    for f in $CHPWD_COMMAND; do
      "$f"
    done
    unset IFS
  fi
  # refresh last working dir record
  export PREVPWD="$PWD"
}

# add `;` after _chpwd_hook if PROMPT_COMMAND is not empty
PROMPT_COMMAND="_chpwd_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"


### Usage

#```bash
## example 1: `ls` list directory once dir is changed
#_ls_on_cwd_change() {
#  ls
#}

## append the command into CHPWD_COMMAND
#CHPWD_COMMAND="${CHPWD_COMMAND:+$CHPWD_COMMAND;}_ls_on_cwd_change"

## or just use `ls` directly
#CHPWD_COMMAND="${CHPWD_COMMAND:+$CHPWD_COMMAND;}ls"
#```
