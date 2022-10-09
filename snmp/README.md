# SNMP

## Get started

To submit some snmp metrics to your account:

1. Create a relevant `.env` file. Run `cp .env.example .env` and edit the `.env` file.
2. Run `docker-compose up`
3. You are done!!

## SNMPSIM

By default, SNMPSim exposes the devices with snmp v1, v2 (v2c) and v3.

SNMPSim reads the device recordings (`.snmprec`) available in `./data` to simulate snmp devices.

### Configuration

By default the snmprec provided display static values. You may be interested in having something varying through time. For that purpose you can actually edit the snmprec following [this doc](http://snmplabs.com/snmpsim/simulation-with-variation-modules.html#numeric-module).

If you don't want to read this, you can change any OID value within your snmprec file from somethimng like:

```
1.3.6.1.2.1.31.1.1.1.6.32|70|457265376
```

To something like:

```
1.3.6.1.2.1.31.1.1.1.6.32|70:numeric|min=0,initial=0,deviation=100000,cumulative=1
```

or like this:

```
1.3.6.1.2.1.31.1.1.1.6.32|70:numeric|scale=10,deviation=10000000,function=cos,cumulative=1,wrap=1
```

Also if you want additional profiles to be loaded, you can change the volume to:

```
- ./data/:/usr/local/share/snmpsim/data
```

#### Side note

As a reference:

- ifHCInOctets: 1.3.6.1.2.1.31.1.1.1.6
- ifHCOutOctets: 1.3.6.1.2.1.31.1.1.1.10

## Datadog Configuration

### Query one device

Change the docker labels to the one below and edit the `community_string` based on the filename found in `./data`:

```
labels:
  com.datadoghq.ad.check_names: '["snmp"]'
  com.datadoghq.ad.init_configs: '[{}]'
  com.datadoghq.ad.instances: '[{ "ip_address": "%%host%%", "port": "1161", "community_string": "f5" }]'
```

### Get all

Change the docker labels to the one below to query all snmp devices:

```
labels:
  com.datadoghq.ad.check_names: '["snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp", "snmp"]'
  com.datadoghq.ad.init_configs: '[{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]'
  com.datadoghq.ad.instances: '[{ "ip_address": "%%host%%", "port": "1161", "community_string": "apc_ups" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "args_list" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "arista" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "aruba" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "chatsworth" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "checkpoint_firewall" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "cisco_asa_5525" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "cisco_nexus" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "cisco_csr1000v" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "constraint" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "dell_poweredge" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "dummy" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "entity" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "f5" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "generic_host" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "hp_ilo4" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "hpe-proliant" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "idrac" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "if" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "isilon" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "meraki-cloud-controller" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "network" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "pan-common" }, { "ip_address": "%%host%%", "port": "1161", "community_string": "public" }]'
```

### Use autodiscovery

Change the docker labels to the one below to use Autodiscovery. Note that in our case, to get something dynamic we had to use `/32`, it is more relevant to have a `/24` (or something else) for real subnets:

```
labels:
  com.datadoghq.ad.check_names: '["snmp"]'
  com.datadoghq.ad.init_configs: '[{}]'
  com.datadoghq.ad.instances: |
    [
    { "network_address": "%%host%%/32", "port": "1161", "community_string": "f5" },
    ]
```

### Configure SNMPv3

FIXME: This is not working at the moment
Change the docker labels to the one below to query with SNMP v3:

```
labels:
  com.datadoghq.ad.check_names: '["snmp"]'
  com.datadoghq.ad.init_configs: '[{}]'
  com.datadoghq.ad.instances: |
    [
    { "ip_address": "%%host%%", "port": "1161", "community_string": "f5", "snmp_version": 3, "user": "simulator", "authProtocol": "MD5", "authKey": "auctoritas", "privProtocol": "DES", "privKey": "privatus" },
    ]
```

## Others

### Check the Datadog config

Connect to the running container:

```
docker exec -it datadog-agent /bin/bash
```

Run:

```
agent status
```

### Run snmpwalk

A few useful commands to play with:

If you are looking for the OID of the `ifHCInOctets` for instance (in this case for an `f5` and at IP `172.26.0.2`):
```
snmpwalk -v2c -On -c f5 172.26.0.2 ifHCInOctets
```

If you are looking for the interface names of the `ifHCInOctets` for instance (in this case for an `f5` and at IP `172.26.0.2`):
```
snmpwalk -v2c -c f5 172.26.0.2 ifHCInOctets
```

**Important note**

If you are looking at accessing the docker container, you may have to change the network configuration. Then you'll have to run:

```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <CONTAINER_ID>
```

TODO: Identify the right network to access the container instance
Try this:
```
my-net:
  driver: macvlan
    driver_opts:
      parent: eno1
    ipam:
      config:
        - subnet: 192.168.0.0/24
          gateway: 192.168.0.1
          ip_range: 192.168.0.40/2
```

## TODO

- Fix the network to query the container from outside
- Embed a dashbord to visualize the data
- Make it work with v3

## Author
* Nicolas Narbais (nicolas.narbais@datadoghq.com)

## Contributor
* Oskar Rittsél (oskar.rittsel@datadoghq.com)
