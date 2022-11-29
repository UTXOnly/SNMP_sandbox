#!/bin/bash

BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' # No Color
cd snmp

#sed script to replace IP address used in conf.yaml to host.docker.internal
sed -r -i '' 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/host.docker.internal/g' ./conf.yaml ./datadog.yaml

echo -e "${BGreen}##################### Creating docker network############################${NC}"
docker network create test-net

echo -e "${BGreen}################# Building docker image##############################${NC}"
docker-compose up --build --force-recreate -d # Add the -d flag to run container in detached mode


echo -e "${BRed}Docker up${NC}"

echo -e "${BGreen}################## TCPDUMP started, please wait 30 seconds #######################################${BRed}"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 
docker exec datadog-agent tcpdump -G 10 port '(161 or 8125)' -W 1 -w /tcpdumps/dump_$(date +'%m-%d-%Y').pcap
echo -e "${NC}\nWriting output of check to ./tcpdump/dump_<DATE>.pcap"

echo -e "${BGreen}################### Running SNMP check ####################################${NC}"
echo -e "${BRed}\nWriting output of check to ./tcpdump/debug_snmp_check.log${NC}"

#Run DEBUG level SNMP check, out put to file locally
docker exec datadog-agent bash -c 'agent check snmp -l debug > /tcpdumps/debug_snmp_check.log'

echo -e "${BGreen}\nDo you want to open the .pcap file in Wireshark now? (y|n)${NC}?"
read ANSWER
if [[ $ANSWER == yes || $ANSWER == y ]]; then
    if [ "$(uname)" == "Darwin" ]; then
        if [ -f /Applications/Wireshark.app ]; then
            open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap
        else 
            brew install wireshark
            open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap
        fi      
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Do something under GNU/Linux platform
        if [ -f /etc/wireshark ]; then
            wireshark ./tcpdump/*.pcap
        else
            sudo apt install wireguard -y
            wireshark ./tcpdump/*.pcap
        fi
    fi
else
    echo -e "${BGreen}Skipping Wireshark finishing install${NC}"
fi