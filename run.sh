#!/bin/bash
source ./snmp/.env
BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' # No Color

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

./parse_conf.sh

cd snmp
echo -e "${BGreen}##################### Creating docker network############################${NC}"
#docker network create static-network

echo -e "${BGreen}################# Building docker image##############################${NC}"
docker network create static-network
# Creates a Datadog container with tcpdump running inside
docker-compose up --build --force-recreate -d # Add the -d flag to run container in detached mode

echo -e "${BRed}\nDocker up${NC}"

echo -e "${BGreen}\n################## TCPDUMP started, please wait 30 seconds #######################################\n${BRed}"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 

docker exec datadog-agent tcpdump -T snmp -c 250 -w /tcpdumps/dump$(date +'%m-%d-%Y').pcap

echo -e "${NC}\nWriting output of check to ./tcpdump/dump_$(date +'%m-%d-%Y').pcap"

echo -e "${BGreen}\n################### Running SNMP check ####################################${NC}"
echo -e "${BRed}\nWriting output of check to ./tcpdump/debug_snmp_check.log${NC}"

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