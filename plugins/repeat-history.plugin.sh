#!/bin/bash
cite about-plugin
about-plugin 'A small but useful command for a linux shell Using the fuzzy finder It makes the bash history more easily accessible using "rh" function'
function rh(){
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:-1,bg:-1,hl:#517599 --color=fg+:#cc6262,bg+:#262626,hl+:#5fd7ff --color=info:4,prompt:#ff1279,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

    if [[ -z $_FILTER ]]; then
        _FILTER="fzf:fzy:fzf-tmux:peco:percol:gof:pick:icepick:sentaku:selecta"
    fi


searchWord="$1"

if [[ $# -gt 1 ]]
then
    size="$2"
else
    size=20000
fi

OLDIFS=$IFS

IFS='
'
if [[ $# -eq 0 ]]
	then
		output=$(cat $HISTFILE | sed '/^#/d' | grep "$searchWord" | grep -v "rh " | tail -n $size)
	else
		output=$(cat $HISTFILE | grep "$searchWord" | grep -v "rh " | tail -n $size | uniq -f 1)
fi
outputArray=($output)

IFS=$OLDIFS

# Print all possible commands
for ((i=0;i<${#outputArray[@]};i++))
do
    echo -e "${outputArray[$i]}" >> ~/.repeat-history
done

if [[ ${#outputArray[@]} -gt 0 ]]
then
    #read -p "Enter the number of desired command: " input
	if [[ _FILTER="fzf"  ]]
		then
			command=$(cat ~/.repeat-history |fzf --inline-info --exact --border --reverse --cycle  --height=45% --query "$READLINE_LINE" --prompt='Search History: ')
	elif [[ _FILTER="fzy"  ]]
		then
			command=$(cat ~/.repeat-history |fzy --query "$READLINE_LINE" --prompt='Search History: ')
	else
			command=$(cat ~/.repeat-history |fzy --query "$READLINE_LINE" --prompt='Search History: ')
	fi
	#command=$(cat ~/.repeat-history |fzf -e)
    #isNumber=$(echo "$input" | egrep '^[0-9]+$')

    # Check on validity
    #if [[ -z "$isNumber" || "$input" -ge $size ]]
    #then
     #   echo "input is not valid."
    #else
        #command=${outputArray[$input]}
        # execute command
        #eval $command
		READLINE_LINE=${command}
        # custom append the executed command to the history
        history -s "$command"
        rm -rf ~/.repeat-history
        
    #fi
fi
}
bind -x '"\C-r": "rh"'
