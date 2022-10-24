#!/bin/bash

vagrant up
wait
sleep 20
echo "sleep finished"

cd ./snmp
echo "changed directory"
docker network create test-net
docker-compose build --no-cache
docker-compose up -d 
echo "docker up"
vagrant ssh

#datadog-agent snmp walk 192.168.1.153 1.3.6.1 -v 2 -C ipsec
