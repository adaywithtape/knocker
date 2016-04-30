#!/bin/bash
# knocker.sh v0.1b
# last edit 09-03-2016 21:30
#
#						VARIABLES
########################################################################
VAR=0
VERS=$(sed -n 2p $0 | awk '{print $3}')
COUNT=1
RETRY=0
SLEEP=1
#
#						TEH COLORZ
########################################################################
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")		#Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")		#Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
ORN=$(echo -e "\e[1;33m")		#Alter fonts to orange bold
ORNN=$(echo -e "\e[0;33m")		#Alter fonts to orange bold
BLU=$(echo -e "\e[1;36m")		#Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
#						HEADER
########################################################################
f_header() {
echo $BLU" _               _           
| |_ ___ ___ ___| |_ ___ ___ 
| '_|   | . |  _| '_| -_|  _|
|_,_|_|_|___|___|_,_|___|_|"
}
#						HELP
########################################################################
f_help() {
f_header
echo $BLU">$BLUN Help Information$STD"
echo "
Usage; 
./knocker.sh -i <IP> -p <PORT,PORT,PORT>

Required Input
-i  --  IP ADDRESS
-p  --  Ports (comma seperated for multiple ports)

Options
-c  --  Number of times each knock to be done (default=1)
-n  --  NetCat connect to port and read returned port values
        (this option then uses returned ports to knock and ignores -p)
-r  --  Number of times to repeat the command (default=0)
-s  --  Sleep inbetween knocks in seconds (default=1)

Examples
./knocker.sh -i 192.168.1.101 -p 1243,65111,1337
[will knock on each of the given ports 1 time]

./knocker.sh -i 192.168.1.101 -n 1337 -r 5
[will attempt connection with netcat on port 1337 and knock on the returned values]
[this command will be repeated 5 times                                            ]

./knocker.sh -i 192.168.1.101 -p 123,456.789 -c 2 -s 2 -r 3
[knock on each given port 2x, sleep 2 seconds between knock, repeat this command 3x]
"
exit
}
#						VERSION
########################################################################
f_version() {
clear
f_header
echo $GRNN"  Version $VERS    By TAPE$STD"
echo -e $BLU">$BLUN Knock Knock.. Who's there?$STD\n"
exit
}
#						NETCAT CONNECT FUNCTION						
########################################################################
f_nc() {
f_header
echo $BLU">$BLUN Using data from nc connection attempt$STD"
if [ "$RETRY" == "0" ] ; then
	VAR=$(($VAR+1))
	echo -e $BLU"\nKnock #$VAR..$STD"
	for i in $(nc $IP $NCPORT | sed -e 's/\[//' -e 's/,//g' -e 's/\]//' -e 's/ /\n/g') ; do 
		echo $GRNN"+$STD Knocking on port $i$STD"
		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		sleep $SLEEP
	done
	echo ""
elif [ $RETRY -gt 0 ] ; then 
	while (( $VAR<$RETRY )) ; do
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
		for i in $(nc $IP $NCPORT | sed -e 's/\[//' -e 's/,//g' -e 's/\]//' -e 's/ /\n/g') ; do 
			echo "+ Knocking on port $i"
			hping3 -S $IP -p $i -c $COUNT &> /dev/null
			sleep $SLEEP
		done
	done
	echo ""
fi
}
#						BASIC KNOCK
########################################################################
f_basic() {
f_header
echo $BLU">$BLUN Knocking given ports$STD"
if [ "$RETRY" == "0" ] ; then
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
	for i in $(echo $PORTS) ; do 
		echo "+ Knocking on port $i"
		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		sleep $SLEEP
	done
elif [ $RETRY -gt 0 ] ; then 
	while (( $VAR<$RETRY )) ; do
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
		for i in $(echo $PORTS) ; do 
			echo "+ Knocking on port $i"
			hping3 -S $IP -p $i -c $COUNT &> /dev/null
			sleep $SLEEP
		done
	done
fi
echo $STD""
}
#						OPTION FUNCTIONS
########################################################################
#	
	
while getopts ":c:hi:n:p:r:s:v" opt; do
  case $opt in
	c)
	COUNT=$OPTARG ;;
	h) 
	f_help ;;
	i)
	IP=$OPTARG ;;
	n)
	NCPORT=$OPTARG ;;
	p)
	PORTS=$OPTARG ;;
	r)
	RETRY=$OPTARG ;;
	s)
	SLEEP=$OPTARG ;;
	v)
	f_version ;;
  esac
done
#
#						INPUT CHECKS
########################################################################

if [ $# -eq 0 ]; then clear ; f_help
elif [[ -z $IP ]] ; then 
	echo $RED">$STD Missing input; IP address must be entered with -i switch"
	exit
elif [[ ! -n $PORTS && ! -n $NCPORT ]] ; then 
	echo $RED">$STD Missing input; no ports defined to knock"
	exit
fi


#
#						START THE KNOCKING
########################################################################

PORTS=$(echo $PORTS | sed 's/,/ /g')



if [[ -n $IP && -n $PORTS ]] ; then
	f_basic
elif [[ -n $IP && -n $NCPORT ]] ; then
	f_nc
fi

# THE END :D
# v0.1b 
# -----
# Created this script after getting seriously frustrated with a vulnhub VM called knockknock
# The script's usefulness is probably limited to this VM, possibly other similar types of 
# deliberately vulnerable VMs.
#
# Real-World applications ... probably limited :) but fun to write and will be fun to build on.
