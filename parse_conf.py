#!/usr/bin/env python3
import re
from ruamel.yaml import YAML
import logging
import os

# Setup logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# Load the YAML file into a dictionary safely
with open('./snmp/dd_config_files/conf.yaml') as file:
    yaml = YAML(typ='safe')
    config = yaml.load(file)
    logger.debug("Loaded configuration from %s", file.name)

# Extract all IP addresses from instances section
ip_addresses = []
for instance in config.get('instances', []):
    ip_address = instance.get('ip_address')
    if ip_address is not None:
        ip_addresses.append(ip_address)
        logger.debug("Extracted IP address %s from configuration", ip_address)

docker_compose_file = './snmp/docker-compose.yaml'

with open(docker_compose_file, "a") as compose_file:
    for ip_address in ip_addresses:
        ips_with_dashes = ip_address.replace('.', '-')
        ip_address_str = str(ip_address)
        compose_file.write(f'''
  container-{ips_with_dashes}:
    container_name: {ips_with_dashes}-container
    image: bhartford419/snmp_container:latest
    environment:
      - DD_TAGS=snmp_container:{ip_address_str}
    ports:
      - "161"
    volumes:
      - ./data/:/usr/local/share/snmpsim/data
    networks:
      static-network:
        ipv4_address: {ip_address_str}
''')
    logger.debug("Wrote container info to %s", docker_compose_file)

with open('./snmp/dd_config_files/conf.yaml') as file:
    config2 = file.read()

    network_address = re.search(r'^\s*network_address:\s*(.+)$', config2, re.MULTILINE)
    if network_address:
        address = network_address.group(1)
        print(f"Found network address: {address}")
    else:
        print("Network address not found in configuration")

    #network_address = re.search(r'^\s*network_address:\s*(.+)$', config, re.MULTILINE)
with open(docker_compose_file, "a") as compose_file:
    for host in range(13, 15):
        compose_file.write(f'''
  container-172-20-0-{host}:
      container_name: 172.20.0.{host}-container
      image: bhartford419/snmp_container:latest
      environment:
        - DD_TAGS=snmp_container:172.20.0.{host},auto-discovery:auto-discovered-device
      ports:
        - "161"
      volumes:
        - ./data/:/usr/local/share/snmpsim/data
      networks:
        static-network:
          ipv4_address: 172.20.0.{host}
    ''')

    logger.debug("Appended additional container info to %s", docker_compose_file)

# Append container info to docker-compose.yaml file for each IP address
    compose_file.write(f'''

networks:
  static-network:
    ipam:
      config:
        - subnet: 172.20.0.0/24
    ''')





