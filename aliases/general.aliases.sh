#!/usr/bin/env bash
#  ---------------------------------------------------------------------------
# OSH_LOAD_PRIORITY=150
cite about-alias
about-alias 'This file holds all general BASH aliases'
#  Description:  This file holds all general BASH aliases
#
#  For your own benefit, we won't load all aliases in the general, we will
#  keep the very generic command here and enough for daily basis tasks.
#
#  If you are looking for the more sexier aliases, we suggest you take a look
#  into other core alias files which installed by default.
#
#  ---------------------------------------------------------------------------

#   -----------------------------
#   1.  MAKE TERMINAL BETTER
#   -----------------------------
alias hs='history | grep'
alias a='apt-custom'
alias c='clear'
alias kg='echo terminal123 | sudo -S killall gnome-software'
alias lampp='echo terminal123 | sudo -S /opt/lampp/lampp $1'
alias reload='source ~/.bashrc'
alias z='exec zsh'
if [[ `command -v  cpg > /dev/null 2>&1` && `command -v  mvg > /dev/null 2>&1` ]]
	then
		alias cp='cpg -g'                       
		alias mv='mvg -g' 
	else
		:
fi
if [[ `command -v bat > /dev/null 2>&1` ]]
	then
		alias cat='bat'                        
	else
		:
fi
#alias cp='cp -iv'                           # Preferred 'cp' implementation
#alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
alias wget='wget -c'                        # Preferred 'wget' implementation (resume download)          
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
alias src='source ~/.bashrc'                # src:          Reload .bashrc file
alias ext='extract'
alias bye='exit'

# Common misspellings of oh-my-bash
alias ohbash='oh-my-bash'
alias ohmy='oh-my-bash'
alias mybash='oh-my-bash'
alias my-bash='oh-my-bash'
alias ohmybash='oh-my-bash'
alias obash='oh-my-bash'
alias mbe='oh-my-bash enable'
alias mbd='oh-my-bash disable'
alias mbs='oh-my-bash show'

# Display whatever file is regular file or folder

#if command -v bim > /dev/null 2>&1
#    then
#        alias vim='bim'
#fi
if command -v neofetch > /dev/null 2>&1
then
	alias neofetch='neofetch --colors 1 5 4 7 1 6 --underline_char ▱ '
fi
catt() {
for i in "$@"; do
    if [ -d "$i" ]; then
        ls --color=auto "$i"
    else
        cat -n "$i"
    fi
    
done
}

