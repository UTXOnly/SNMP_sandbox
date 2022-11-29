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

echo -e "${BGreen}################## TCPDUMP started, please wait 30 seconds #######################################${NC}"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 
docker exec datadog-agent tcpdump -G 10 port '(161 or 8125)' -W 1 -w /tcpdumps/dump$(date +'%m-%d-%Y').pcap

echo -e "${BGreen}################### Running SNMP check ####################################${NC}"

#Run DEBUG level SNMP check, out put to file locally
docker exec datadog-agent bash -c 'agent check snmp -l debug > /tcpdumps/debug_snmp_check.log'

