#!/bin/bash

docker-compose down --remove-orphans
docker stop $(docker ps -a -q)
#Only uncomment if you want REMOVE ALL DOCKER IMAGES!!!
#docker rmi $(docker image ls -a -q) -f
sudo rm -r ./snmp/tcpdump
sudo rm -r ./parsed_yaml
if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
    sed -r -i '' '72,$d' ./snmp/docker-compose.yaml
    sed -r -i '' '2808,$d' ./snmp/data/mocksnmp.snmprec
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Linux branch
    sed -i '72,$d' ./snmp/docker-compose.yaml
else
    echo -e "${BRed}\nUnable to detect OS...skipping sed substituion${NC}"
fi
