#!/bin/bash

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
   s
      }
   }'
}

parse_yaml ./snmp/dd_config_files/conf.yaml > parsed_yaml

# Iterate through the IP addresses parsed from conf.yaml > parsed.yaml file
# Creates a new container for each IP address found in conf.yaml
# Also creates containers for auto-discovery subnet, will only auto-discover first network-address key detected

for ip_address in $(awk ' /ip_address/{print $3}' ./snmp/dd_config_files/conf.yaml)
do
    IPs+=( $ip_address )
    IPs_with_dashes=$(sed "s|\.|\-|g" <<<$ip_address )
    tee -a ./snmp/docker-compose.yaml << EOF

  container-${IPs_with_dashes}:
    container_name: ${IPs_with_dashes}-container
    image: bhartford419/snmp_container:latest
    environment:
      - DD_TAGS=snmp_container:${ip_address}
    ports:
      - "161"
    volumes:
      - ./data/:/usr/local/share/snmpsim/data
    networks:
      static-network:
        ipv4_address: ${ip_address}
EOF
done
for ip_address in $(awk ' /network_address/{print $3; exit}' ./snmp/dd_config_files/conf.yaml)
do
    for host in {101..104}
    do
        tee -a ./snmp/docker-compose.yaml << EOF

  container-172-20-0-${host}:
    container_name: 172.20.0.${host}-container
    image: bhartford419/snmp_container:latest
    environment:
      - DD_TAGS=snmp_container:172.20.0.${host},auto-discovery:auto-discovered-device
    ports:
      - "161"
    volumes:
      - ./data/:/usr/local/share/snmpsim/data
    networks:
      static-network:
        ipv4_address: 172.20.0.${host}
EOF
    done
done
tee -a ./snmp/docker-compose.yaml << EOF
networks:
  static-network:
    ipam:
      config:
        - subnet: 172.20.0.0/24
EOF