#!/bin/bash
source ./snmp/.env

docker kill datadog-agent
docker kill $CONTAINER_NAME
docker network rm test-net
docker image rm datadog/agent -f
docker image rm tandrup/snmpsim -f
docker image rm snmp-datadog -f
docker rmi -f $(docker images -aq) #Only uncomment if you want REMOVE ALL DOCKER IMAGES!!!
sudo rm -r ./snmp/tcpdump