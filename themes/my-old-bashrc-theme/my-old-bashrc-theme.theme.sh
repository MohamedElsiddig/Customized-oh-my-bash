#!/usr/bin/env bash
#
# One line prompt showing the following configurable information
# for git:
# time (virtual_env) username@hostname pwd git_char|git_branch git_dirty_status|→
#
# The → arrow shows the exit status of the last command:
# - bold green: 0 exit status
# - bold red: non-zero exit status
#
# Example outside git repo:
# 07:45:05 user@host ~ →
#
# Example inside clean git repo:
# 07:45:05 user@host .oh-my-bash ±|master|→
#
# Example inside dirty git repo:
# 07:45:05 user@host .oh-my-bash ±|master ✗|→
#
# Example with virtual environment:
# 07:45:05 (venv) user@host ~ →
#

SCM_NONE_CHAR=''
SCM_THEME_PROMPT_DIRTY="${bold_yellow} ✗"
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX=" ${bold_blue}git:(${bold_red}"
SCM_THEME_PROMPT_SUFFIX="${bold_blue})"
SCM_GIT_SHOW_MINIMAL_INFO=true
function _ps(){
local RC="$?"

if [[ $RC = 0 ]]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;6m\]﹝\[\033[38;5;118m\]\[\033[38;5;154m\]\[\033[33;1m\]☁  \e[21m\[\033[01;36m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h\[\033[00m\]\[\033[38;5;6m\]﹞\[\033[38;5;118m\]\[\033[0m\]\[\033[38;5;10m\]\[\033[0m\]:﹝\[\033[0m\]\[\033[38;5;118m\]\w\[\033[00m\]﹞  
\342\224\224⌥  \[\033[01;33m\]\\$\[\e[0m\] '
else
 PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;6m\]﹝\[\033[38;5;118m\]\[\033[38;5;154m\]\[\033[33;1m\]☁  \e[21m\[\033[01;36m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h\[\033[00m\]\[\033[38;5;6m\]﹞\[\033[38;5;118m\]\[\033[0m\]\[\033[38;5;10m\]\[\033[0m\]err-﹝\[\033[01;31m\]$?\[\e[0m\]﹞:﹝\[\033[0m\]\[\033[38;5;118m\]\w\[\033[00m\]﹞  
\342\224\224⌥  \[\033[01;33m\]\\$\[\e[0m\] '
fi
 history -a
}


safe_append_prompt_command _ps
