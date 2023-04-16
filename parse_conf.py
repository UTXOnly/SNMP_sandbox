#!/usr/bin/env python3
import re

def parse_yaml(filename, prefix=''):
    data = {}
    with open(filename) as f:
        lines = f.readlines()
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        match = re.findall(r'^\s*([\w.-]+):\s*(.*)$', line)
        if not match:
            continue
        key, value = match[0]
        key = key.replace('-', '_')
        if '.' in key:
            parts = key.split('.')
            d = data
            for part in parts[:-1]:
                d = d.setdefault(part, {})
            d[parts[-1]] = _parse_value(value)
        else:
            data[key] = _parse_value(value)

    result = {}
    for key, value in data.items():
        if prefix:
            key = f"{prefix}_{key}"
        if isinstance(value, dict):
            result.update(parse_yaml(data[key], prefix=key))
        else:
            result[key] = value
    return result


def _parse_value(value):
    try:
        return int(value)
    except ValueError:
        pass
    try:
        return float(value)
    except ValueError:
        pass
    if value == 'true':
        return True
    elif value == 'false':
        return False
    elif value == 'null':
        return None
    elif value.startswith(('"', "'")) and value.endswith(('"', "'")):
        return value[1:-1]
    return value

#!/usr/bin/env python3
import re

with open('./snmp/dd_config_files/conf.yaml') as f:
    config = f.read()

ips = []
for match in re.findall(r'^\s*ip_address:\s*(.+)$', config, re.MULTILINE):
    ips.append(match.strip())

with open('./snmp/docker-compose.yaml', 'a') as f:
    for ip_address in ips:
        IPs = []
        IPs.append(ip_address)
        IPs_with_dashes = ip_address.replace('.', '-')
        f.write(f'''
container-{IPs_with_dashes}:
    container_name: {IPs_with_dashes}-container
    image: bhartford419/snmp_container:latest
    environment:
      - DD_TAGS=snmp_container:{ip_address}
    ports:
      - "161"
    volumes:
      - ./data/:/usr/local/share/snmpsim/data
    networks:
      static-network:
        ipv4_address: {ip_address}
''')


    network_address = re.search(r'^\s*network_address:\s*(.+)$', config, re.MULTILINE)
    for host in range(101, 105):
        f.write(f'''
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


    f.write('''
networks:
  static-network:
    ipam:
      config:
        - subnet: 172.20.0.0/24
    ''')





