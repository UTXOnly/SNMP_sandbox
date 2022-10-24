#!/bin/bash

vagrant destroy -f
wait
docker kill dd-snmp
docker network rm test-netß