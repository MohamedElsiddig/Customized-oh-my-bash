#!/bin/bash
cite about-plugin
about-plugin 'This plugin provides functions to show you your system information or diagnostic your system'
######################

#Color Schemas

###########################

system-diagnostic(){

echo -e " ${echo_bold_yellow}[*]${echo_normal} Choose one of the following options"
echo ""
echo -e "\t${echo_bold_cyan}[1]${echo_normal} Show boot Time"
echo -e "\t${echo_bold_cyan}[2]${echo_normal} Show boot Digram"
echo -e "\t${echo_bold_cyan}[3]${echo_normal} Show Systemd status"
echo -e "\t${echo_bold_cyan}[4]${echo_normal} List Systemd Failed Services"
echo -e "\t${echo_bold_cyan}[5]${echo_normal} List Systemd Running Jobs"
echo -e "\t${echo_bold_cyan}[6]${echo_normal} Check The System Journal"
echo -e "\t${echo_bold_cyan}[7]${echo_normal} Free Space From The System Journal"
echo -e "\t${echo_bold_cyan}[8]${echo_normal} Check The Kernel Messages\n"
echo -en " ${echo_bold_yellow}[*]${echo_normal} Enter The Number of Selected Option: "
read  var
echo " "

if [[ -n $var && $[var] != $var ]]
    then
        echo -e "${echo_bold_red}\"$var\" is Not an Option!${echo_normal}"
elif [ -z $var ] 
    then
        echo -e "${echo_bold_red} Wrong choice ${echo_white}[Please Select one of the Options 1 ~ 8]${echo_normal}"
elif [ $var -eq 1 ] 
    then
        echo -e "${echo_background_blue}***** Showing Boot Time *****${echo_normal}\n"
        sleep 1
        systemd-analyze
        echo " "
elif [ $var -eq 2 ] 
    then
        echo -e "${echo_background_blue}***** Creating boot.svg file *****${echo_normal}\n"
        #echo "Creating boot.svg file"
        sleep 2
        systemd-analyze plot > /home/$USER/boot.svg 
        echo -e "${echo_bold_cyan}[!]${echo_white} Starting Browser To view the Digram${echo_normal}"
        sleep 2 ;
        x-www-browser ~/boot.svg
        echo -e "${echo_bold_cyan}[!]${echo_white} Removing boot.svg${echo_normal}"
        sleep 2
        rm -rf ~/boot.svg
        echo " "
elif [ $var -eq 3 ]
    then
        echo -e "${echo_background_blue}***** Showing Systemd Status *****${echo_normal}"
        #echo "Showing Systemd Status"
        sleep 2
        systemctl status
        echo " "
elif [ $var -eq 4 ]
    then
        echo -e "${echo_background_blue}***** Showing Systemd Failed Serivces *****${echo_normal}"
        #echo "Showing Systemd Failed Serivces"
        echo " "
        sleep 2
        systemctl list-units --failed
        echo " "
elif [ $var -eq 5 ]
    then
        echo -e "${echo_background_blue}***** Showing Systemd Running Jobs *****${echo_normal}\n"
        #echo "Showing Systemd Running Jobs"
        echo " "
        sleep 2
        systemctl list-jobs
        echo " "
elif [ $var -eq 6 ]
    then
        echo -e "${echo_background_blue}***** Checking The System Journal *****${echo_normal}\n"
        #echo "Checking The System Journal"
        echo " "
        sleep 2
        journalctl -xe
        echo " "
elif [ $var -eq 7 ]
    then
        echo -e "${echo_background_blue}***** Freeing Some space *****${echo_normal}"
        #echo "Freeing Some space"
        echo " "
        sleep 2
        if [ $UID != 0 ]
            then
                echo -e "${echo_bold_red}[!]${echo_normal}${echo_bold_white} You Need root Perminssions${echo_normal} \n"
                echo -en "${echo_bold_green} Enter The sudo command: ${echo_normal}"
                read  s
                $s -S journalctl --vacuum-time=1d
        fi
        echo " "
elif [ $var -eq 8 ]
    then
        echo -e "${echo_background_blue}***** Showing The Kernel Messages *****${echo_normal}\n"
        #echo -e "Showing The Kernel Messages"
        sleep 1
        dmesg -H
else
        echo " "
        echo -e "${echo_bold_red} Please Choose From Above Options${echo_normal}"
fi
}

system_info(){

# This script will return the following set of system information:
# -Hostname information:
echo -e "${echo_background_blue}***** HOSTNAME INFORMATION *****${echo_normal}"
sleep 2
hostnamectl
echo ""
# -File system disk space usage:
echo -e "${echo_background_blue}***** FILE SYSTEM DISK SPACE USAGE *****${echo_normal}"
sleep 2
df -h
echo ""
# -Free and used memory in the system:
echo -e "${echo_background_blue} ***** FREE AND USED MEMORY *****${echo_normal}"
sleep 2
free
echo ""
# -System uptime and load:
echo -e "${echo_background_blue}***** SYSTEM UPTIME AND LOAD *****${echo_normal}"
sleep 2
uptime
echo ""
# -Logged-in users:
echo -e "${echo_background_blue}***** CURRENTLY LOGGED-IN USERS *****${echo_normal}"
sleep 2
who
echo ""
# -Top 5 processes as far as memory usage is concerned
echo -e "${echo_background_blue}***** TOP 5 MEMORY-CONSUMING PROCESSES *****${echo_normal}"
sleep 2
ps -eo %mem,%cpu,comm --sort=-%mem | head -n 6
echo ""
sleep 2
echo -e "${echo_bold_green} Done.${echo_normal}"


}

sysd(){
		about 'Helpfull System Diagnostic tool'
		group 'misc'
		echo -e "${echo_bold_yellow}[*]${echo_normal} What Do you want to check"
	select options in "System Diagnostics" "System information"
		do
			case $options in
				"System Diagnostics")
					sleep 0.5
					echo ""
					system-diagnostic 
					break ;; 
				"System information")
					sleep 0.5
					echo ""
					system_info
					break ;;
				*) 
					echo -e "\n"
					reference sysd
					 break ;;
				esac
				done
}
