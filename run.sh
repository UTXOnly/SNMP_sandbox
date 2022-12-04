#!/bin/bash

BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' # No Color
con_name=snmp_dev_1

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

parse_yaml ./snmp/dd_config_files/conf.yaml

if [ "$(uname)" == "Darwin" ]; then
    #sed script to replace IP address used in conf.yaml to host.docker.internal
    sed -r -i '' 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/host.docker.internal/g' ./snmp/dd_config_files/conf.yaml ./snmp/dd_config_files/datadog.yaml
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo sed -i 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/${con_name}/g' ./snmp/dd_config_files/conf.yaml #./snmp/dd_config_files/datadog.yaml
else
    echo "${BRed}Unable to detect OS${NC}"
fi

cd snmp
echo -e "${BGreen}##################### Creating docker network############################${NC}"
docker network create test-net

echo -e "${BGreen}################# Building docker image##############################${NC}"
docker-compose up --build --force-recreate -d # Add the -d flag to run container in detached mode

echo -e "${BRed}\nDocker up${NC}"

echo -e "${BGreen}\n################## TCPDUMP started, please wait 30 seconds #######################################\n${BRed}"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 
docker exec datadog-agent tcpdump -c 150 -w /tcpdumps/dump$(date +'%m-%d-%Y').pcap
echo -e "${NC}\nWriting output of check to ./tcpdump/dump_$(date +'%m-%d-%Y').pcap"

echo -e "${BGreen}\n################### Running SNMP check ####################################${NC}"
echo -e "${BRed}\nWriting output of check to ./tcpdump/debug_snmp_check.log${NC}"

#Run DEBUG level SNMP check, out put to file locally
docker exec datadog-agent bash -c 'agent check snmp -l debug > /tcpdumps/debug_snmp_check.log'

echo -e "${BGreen}\nDo you want to open the .pcap file in Wireshark now? (y|n)${NC}?"
read ANSWER
if [[ $ANSWER == "yes" || $ANSWER == "y" ]]; then
    if [ "$(uname)" == "Darwin" ]; then
        if [ -d /Applications/Wireshark.app ]; then
            open -n -a /Applications/Wireshark.app ./tcpdump/dump$(date +'%m-%d-%Y').pcap
        else 
            brew install wireshark
            open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap
        fi      
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Do something under GNU/Linux platform
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
