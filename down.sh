#!/bin/bash


docker kill datadog/agent
docker kill tandrup/snmpsim
docker network rm test-net
docker image rm datadog/agent -f
docker image rm tandrup/snmpsim -f