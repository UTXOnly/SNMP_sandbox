#!/bin/bash
source ./snmp/.env

docker-compose down --rmi all --remove-orphans
docker stop $(docker ps -a -q)
#Only uncomment if you want REMOVE ALL DOCKER IMAGES!!!
docker rmi $(docker image ls -a -q) -f
sudo rm -r ./snmp/tcpdump
sudo rm -r ./parsed_yaml