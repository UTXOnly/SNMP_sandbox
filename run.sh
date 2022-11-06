#!/bin/bash
cd snmp

#sed script to replace IP address used in conf.yaml to host.docker.internal
sed -r -i '' 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/host.docker.internal/g' ./conf.yaml ./datadog.yaml

echo "##################### Creating docker network############################"
docker network create test-net

echo "################# Building docker image##############################"
docker-compose up --build --force-recreate -d # Add the -d flag to run container in detached mode


echo "Docker up"

echo "################## TCPDUMP started, please wait 30 seconds #######################################"
#Starting a tcpdump filtering traffic on port 161 to closer inspect 
docker exec datadog-agent tcpdump -G 30 port '(161 or 8125)' -W 1 -w /tcpdumps/dump$(date +'%m-%d-%Y').pcap

echo "################### Running SNMP check ####################################"

#docker exec datadog-agent touch /tcpdumps/debug_snmp_check.txt && \
docker exec datadog-agent agent check snmp -l debug > ./"status&tcpdump"/debug_snmp_check.log

