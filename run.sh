#!/bin/bash
source ./snmp/.env
BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BGreen}\nWould you like to:\n1) Monitor Individual Devices\n2) Test Autodiscovery\n${NC}\nPlease select 1 or 2 and press ENTER\n"
read AD_ANSWER

if [ $AD_ANSWER == 1 ]; then
    ./parse_conf.sh ${AD_ANSWER}
elif [ $AD_ANSWER == 2 ]; then
    ./parse_conf.sh ${AD_ANSWER}
else
    echo -e "\n${BRed}Invalid selectiong, moving on...${NC}"
fi
cd snmp
echo -e "${BGreen}##################### Creating docker network############################${NC}"
docker network create static-network

echo -e "${BGreen}################# Building docker image##############################${NC}"

# Creates a Datadog container with tcpdump running inside
docker-compose up --build --force-recreate -d # Add the -d flag to run container in detached mode

echo -e "${BRed}\nDocker up${NC}"

echo -e "${BGreen}\n################## TCPDUMP started, please wait 30 seconds #######################################\n${BRed}"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 

docker exec datadog-agent tcpdump -T snmp -c 400 -w /tcpdumps/dump$(date +'%m-%d-%Y').pcap

echo -e "${NC}\nWriting output of check to ./tcpdump/dump_$(date +'%m-%d-%Y').pcap"

echo -e "${BGreen}\nRunning comparison of OID's configured in profile to OID in snmprec${NC}"
echo -e "${BRed}\nThe following OID's in your snmp profile were configured\n${NC}"
cd ..
python3 compare.py

echo -e "${BGreen}\n################### Running SNMP check ####################################${NC}"
echo -e "${BRed}\nWriting output of check to ./tcpdump/debug_snmp_check.log${NC}"
cd snmp

#Run DEBUG level SNMP check, out put to file locally
docker exec datadog-agent bash -c 'agent check snmp -l debug > /tcpdumps/debug_snmp_check.log'

echo -e "${BGreen}\nDo you want to open the .pcap file in Wireshark now? (y|n)${NC}?"
read ANSWER
if [[ $ANSWER == "yes" || $ANSWER == "y" ]]; then
    if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
        if [ -d /Applications/Wireshark.app ]; then
            open -n -a /Applications/Wireshark.app ./tcpdump/dump$(date +'%m-%d-%Y').pcap
            open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap
        else 
            brew install wireshark
            open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap
        fi      
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Linux branch
        if [ -d /etc/wireshark ]; then
            wireshark "./tcpdump/dump$(date +'%m-%d-%Y').pcap"
        else
            sudo apt install wireguard -y
            wireshark ./tcpdump/dump$(date +'%m-%d-%Y').pcap
        fi
    fi
else
    echo -e "${BGreen}Skipping Wireshark finishing install${NC}"

fi
