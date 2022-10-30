#!/bin/bash
cd snmp
#sed script to replace IP address used in conf.yaml to host.docker.internal
sed -r -i '' 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/host.docker.internal/g' ./conf.yaml

echo "Creating docker network############################"
docker network create test-net

echo "Building docker image##############################"
docker-compose up --build --force-recreate

echo "Docker up"