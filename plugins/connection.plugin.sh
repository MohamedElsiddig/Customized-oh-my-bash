#!/bin/bash
cite about-plugin
about-plugin 'This plugin helps you to check your internet connection status'
#################################################
#Check netspeed function got it from https://github.com/timjaanson/netspeed/blob/master/netspeed.sh
#################################################

netspeed(){
calcDelay=85 #in ms
unit=1
unitMarking="B"
interface=":"
formatValue=""
interval=1
count=1
infinite=0


#while getopts 'bBf:I:i:c:h' OPTION; do
#  case "$OPTION" in
#    b)
#      unit=8
#      unitMarking="b"
#      ;;
#    B)
#      unit=1
#      unitMarking="B"
#      ;;

#    f)
#      formatValue="$OPTARG"
#      ;;

#    I)
#      interface="$OPTARG"
#      ;;

#    i)
#      interval="$OPTARG"
#      
#      ;;

#    c)
#      count="$OPTARG"
#      if (( count == 0));then
#          infinite=1
#      fi
#      ;;
#    ?)
#      #echo "script usage: $(basename $0) [-I <interface>]" >&2
#			:
#      ;;
#  esac
#done
shift "$(($OPTIND -1))"

fullCalcDelay=$((interval * 1000 + calcDelay))
getCurrentBytes () {
    N=0
    for i in $(awk '/:/ { print($1, $2, $10) }' < /proc/net/dev | grep "${1}")
    do
      initBytes[$N]="$i"
      let "N= $N + 1"
    done
}

printValue () {
    getCurrentBytes $3
    initRX=0
    initTX=0
    N=0
    for i in "${initBytes[@]}"
    do
        if [[ $(( N % 3 )) == 1 ]]
        then
	          initRX=$((${initRX} + ${i}))
        elif [[ $(( N % 3 )) == 2 ]]
        then
	          initTX=$((${initTX} + ${i}))
        fi
        let "N= $N + 1"
    done

    sleep ${4}

    finalRX=0
    finalTX=0
    getCurrentBytes $3
    N=0
    for i in "${initBytes[@]}"
    do
        if [[ $(( N % 3 )) == 1 ]]
        then
	          finalRX=$((${finalRX} + ${i}))
        elif [[ $(( N % 3 )) == 2 ]]
        then
	          finalTX=$((${finalTX} + ${i}))
        fi
        let "N= $N + 1"
    done

    downloadSpeed=$(( ($finalRX - $initRX) * ${1}))
    downloadSpeed=`echo ${downloadSpeed} ${2} ${4} 1000 ${5} | awk '{printf "%.2f \n", $1/$2/$5*($3*$4)}'`
    uploadSpeed=$(( ($finalTX - $initTX) * ${1}))
    uploadSpeed=`echo ${uploadSpeed} ${2} ${4} 1000 ${5} | awk '{printf "%.2f \n", $1/$2/$5*($3*$4)}'`
    echo "${downloadSpeed}   ${uploadSpeed}"
}

if [[ $formatValue == "k" || $formatValue == "K" ]]
then
    format=1000
    formatValue="k"
elif [[ $formatValue == "M" || $formatValue == "m" ]]
then
    format=1000000
    formatValue="M"
elif [[ $formatValue == "G" || $formatValue == "g" ]]
then
    format=10000000000
    formatValue="G"
else
    format=1000
    formatValue="k"
fi


echo	"download upload [${formatValue}${unitMarking}/s]"
h=0
while (( h < count || infinite == 1 ))
do
    printValue $unit $format $interface $interval $fullCalcDelay
    ((h+=1))
done

return 0
}


##################################################
#Check internet connection function
##################################################

function chick_net()
{
    clear
    echo ""
    echo -e ${echo_bold_cyan} "[ * ]${echo_bold_blue} Checking for internet connection\n"
    sleep 1
    echo -e "GET http://google.com HTTP/1.0\n\n" | nc -w 3 google.com 80 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e ${echo_bold_red} [ X ]::${echo_bold_white}[Internet Connection]:${echo_bold_red} OFFLINE! ${echo_normal};
        chknet
        sleep 1
    else
        echo -e ${echo_bold_green} [ ✔ ]${echo_bold_white}::${echo_bold_white}[Internet Connection]:${echo_bold_green} CONNECTED! ${echo_normal};
        echo ""
        echo -e ${echo_yellow}"|${echo_bold_white}---------------------------------------------------${echo_yellow}|${echo_normal}"
        echo ""
        sleep 1
        private_ip_vpn=`ip route get 8.8.4.4 | head -1 | awk '{print $7}'`
        if [[ -z $private_ip_vpn ]] ; then
            echo -e ${echo_bold_red} [ X ]${echo_bold_white}::${echo_bold_white}[Couldn\'t get Private ip address For The Machiane]:${echo_bold_red} Network is unreachable! ${echo_normal};
            echo ""   
        elif [[ $private_ip_vpn != 0 ]]; then
            for network_card in $(ls /sys/class/net/)
                do
                    state=`cat /sys/class/net/$network_card/operstate`
                    if [[ $state = "up" ]] 
                        then
                            echo  $network_card is up > /dev/null 2>&1
                            private_ip=`ip addr | grep $network_card | awk '{print $2}' | cut -f1 -d'/' | sed "/${network_card}/d" | sed '/^$/d'`
                        else
                            echo $network_card not up > /dev/null 2>&1
                    fi
            done
            if [[ $private_ip_vpn != $private_ip ]] 
                then
                    echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[Your Private ip address is]:"${echo_bold_blue} $private_ip ${echo_normal}"\n";
                    sleep 1
                elif [[ $private_ip_vpn = $private_ip ]]  
                    then
                        # private_ip=`ip addr | grep $network_card | awk '{print $2}' | cut -f1 -d'/' | sed "/${network_card}/d" | sed '/^$/d'`
                        echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[Your Private ip address is]:"${echo_bold_blue} $private_ip_vpn ${echo_normal}"\n";
                    else
                        echo -e ${echo_bold_red} [ X ]${echo_bold_white}::${echo_bold_white}[Couldn\'t get Private ip address For The Machiane]:${echo_bold_red} Network is unreachable! ${echo_normal};
                        echo ""    
            fi
            sleep 1
            if [[ $private_ip_vpn != $private_ip ]] 
                then
                    echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[Your Private ip address For VPN is]:"${echo_bold_blue} $private_ip_vpn ${echo_normal}"\n";
                else
                    echo -e ${echo_bold_red} [ X ]${echo_bold_white}::${echo_bold_white}[Couldn\'t get Private ip address For VPN]:${echo_bold_red} You are Not Connected to VPN! ${echo_normal};
                    echo ""
            fi
        fi
        
        public_ip=`wget --timeout=2 --tries=3 https://ipecho.net/plain -O - -q`
        if [ $? -eq 0 ]; then
            sleep 1
            echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[Your Public ip address is]:"${echo_bold_blue} $public_ip ${echo_normal};
            echo ""
        else
            echo -e ${echo_bold_red} [ X ]${echo_bold_white}::${echo_bold_white}[Couldn\'t get Public ip address]:${echo_bold_red} Due Bad Connection! ${echo_normal};
            echo ""
        fi
        
        error=`curl -s --connect-timeout 4 https://ipinfo.io/$public_ip/country | grep Error | cut -f2 -d'<' | cut -f2 -d'>'`
        if [[ $error != "Error" ]] 
            then
                country_id=`curl -s --connect-timeout 4 https://ipinfo.io/country`
                if [[ ! -z $country_id ]]
                    then
                        :
                    else
                        country_id="${echo_bold_red} Couldn't Get Country ID${echo_bold_blue}"
                fi

            else
                country_id="${echo_bold_red} Couldn't Get Country ID${echo_bold_blue}"
        fi
        country_name=`curl -s --connect-timeout 4 https://ipapi.co/$public_ip/json/ | grep country_name | cut -f2 -d'_' | cut -f2 -d':' | cut -f1 -d',' | tr -d "\""`
        if [[ ! -z $country_name && ! -z $country_id ]]; then
            echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[You are Browsing The Internet From]:"${echo_bold_blue} $country_id, $country_name ${echo_normal};
            echo ""
        else
        echo -e ${echo_bold_red} [ X ]${echo_bold_white}::${echo_bold_white}[Couldn\'t get Country Information]:${echo_bold_red} Due Bad Connection! ${echo_normal};
            echo ""
        fi
        download_rate=$(netspeed | awk '{print $1}' | cut -f1 -d'd' | sed '/^$/d')
        upload_rate=$(netspeed | awk '{print $2}' | cut -f1 -d'u' | sed '/^$/d')
        echo -e "${echo_bold_cyan} [ * ]${echo_bold_white}::${echo_bold_white}[Your internet speed is]:"${echo_bold_blue} Donwload:${echo_yellow}${download_rate} ${echo_normal}[kB/s], ${echo_bold_blue}Upload:${echo_yellow}${upload_rate} ${echo_normal}[kB/s] ${echo_normal};
            echo ""
        sleep 1

    fi
}

##################################################
#Check internet connection problem if found function
##################################################

function chknet() {
    echo -e ${echo_bold_red} "[X] Your Internet is not working correctly!" ${echo_normal}
    sleep 1
    echo -e ${echo_cyan} "[*] Checking ...."
    #ping hostname failed , so now will test ping google ip dns server
    ping -c 1 8.8.4.4 > /dev/null 2>&1
    png="$?"
    if [ $png == "0" ]
        then
        #Ping dns server worked , inform user what happened and proceed with Script
            echo -e ${echo_bold_red} "[X] Your linux OS is not able to resolve" ${echo_normal}
            echo -e ${echo_bold_red} "hostnames over terminal using ping !!"
            echo ""
            echo -e ${echo_yellow} "Search on the web : (unable to resolve hostnames ping) to find a solution" ${echo_normal}
            echo ""
            echo -e ${echo_cyan} "Internet may not work because :" ${echo_normal}
            echo -e ${echo_bold_white} "Ping google.com =${echo_bold_red} Failed" ${echo_normal}
            echo -e ${echo_bold_white} "Ping google DNS =${echo_green} Success" ${echo_normal}
            echo ""
            echo -e ${echo_green} "Press [ENTER] key to continue" ${echo_normal}
            read -t 3 continue
            return 1
            sleep 1
    elif [ $png == "1" ]
        then
            #Uses is only connected to lan and not to the web , aborting
            echo -e ${echo_yellow} "You are connected to your local network but not to the web ." ${echo_normal}
            echo -e ${echo_yellow} "Check if your router/modem gateway is connected to the web ." ${echo_normal}
            echo ""
            echo -e ${echo_bold_white} "Internet will not work , you are only connected to your local lan." ${echo_normal}
            echo ""
            echo -e ${echo_cyan} "Internet will not work because :" ${echo_normal}
            echo -e ${echo_bold_white} "Ping google.com =${echo_bold_red} Failed" ${echo_normal}
            echo -e ${echo_bold_white} "Ping google DNS =${echo_bold_red} Failed" ${echo_normal}
            echo ""
            echo -e ${echo_green} "Press [ENTER] key to continue" ${echo_normal}
            read -t 3 continue
            return 1
            sleep 1
    elif [ $png == "2" ]
        then
            # user is not connected to anywhere , web or lan , aborting
            echo -e ${echo_bold_red} "You are not connected to any network ." ${echo_normal}
            echo ""
            echo -e ${echo_cyan} "Internet will not work because :" ${echo_normal}
            echo -e ${echo_bold_white} "Ping google.com =${echo_bold_red} Failed${echo_normal}"
            echo -e ${echo_bold_white} "Ping google DNS =${echo_bold_red} Failed${echo_normal}"
            echo ""
            echo -e ${echo_green} "Press [ENTER] key to continue${echo_normal}"
            read -t 3 continue
            return 1
            sleep 1
    fi
}

connection(){
about 'check your internet connection status'
group 'misc'

chick_net

}
alias con='connection'
