SCM_THEME_PROMPT_PREFIX=" ${bold_green}(git:"
SCM_THEME_PROMPT_SUFFIX="${bold_green})"
SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=""
SCM_GIT_SHOW_MINIMAL_INFO=true

function prompt_command() {
    # This needs to be first to save last command return code
    local RC="$?"

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${yellow}"
    else
        ret_status="${bold_red}"
    fi


    # Append new history lines to history file
    history -a

    PS1="$(battery_percentage)
 ${yellow}\W ${ret_status}➤ ${normal}$(scm_prompt_info)${normal} "
}

safe_append_prompt_command prompt_command


