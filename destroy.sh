#!/bin/bash


docker kill datadog-agent
docker kill dd-snmp
docker network rm test-net
docker image rm datadog/agent -f
docker image rm tandrup/snmpsim -f
docker image rm snmp-datadog -f

