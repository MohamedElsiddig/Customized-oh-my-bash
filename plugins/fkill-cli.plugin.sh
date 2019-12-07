#!/bin/bash
cite about-plugin 
about-plugin 'Fabulously kill processes in intractive way using fuzzy finder'


function fkill(){
if [[ `which fzf` ]]
	then
		fuzzy_command=fzf
	else
		fuzzy_command=""
fi
if [[ ! -z $fuzzy_command ]]
	then
		process=`ps -A | awk '{print $1 "\t" $4}' | $fuzzy_command --reverse --border --prompt=Running\ processes:  | awk '{print $1}'`
		if [[ ! -z $process ]] 
			then
				process_name=`ps -p $process -o comm=`
				kill -9 $process > /dev/null 2>&1
				if [[ $? == 0 ]]
					then
						echo ""
						echo -e ${echo_bold_green} ✔${echo_bold_yellow} Process $process_name [ id = $process ] were killed successfully${echo_normal}
					else
						echo -e ${echo_bold_red} ✘${echo_bold_yellow} Failed to kill Process $process_name [ id = $process ] ${echo_normal}
				fi
			else
				:
		fi
		else
		echo ""
		echo -e ${echo_bold_red} ✘${echo_bold_yellow} You Dont have fzf command in your path please download it${echo_normal}
		
fi

}
