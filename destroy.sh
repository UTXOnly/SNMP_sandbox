#!/bin/bash
source ./snmp/.env

docker kill datadog-agent
docker kill *-container
docker network rm static-network
docker image rm datadog/agent -f
docker image rm bhartford419/*-container -f
docker rmi -f $(docker images -aq) #Only uncomment if you want REMOVE ALL DOCKER IMAGES!!!
sudo rm -r ./snmp/tcpdump
sudo rm -r ./parsed_yaml