# SNMP_sandbox                                                                                               
                                                                                                        

A sandbox environment for testing custom SNMP profiles with Datadog Network Device Management. By adding your own Datadog API key to an `.env` file, then running a simple run script, you can validate your custom SNMP profile with the help of a mock SNMP device running in another Docker container. This program is mimics network devices by running [Pysnmp](https://github.com/etingof/pysnmp) containers serving the metrics available from your snmpwalk to be polled by the Datadog agent.

##### Use Case
To validate custom SNMP profiles along with Datadog agent configuration
* Validate `conf.yaml` and `custom_profile` configuration in Datadog agent
* Simulate a SNMP device being polled and reporting metrics to Datadog agent
* Validate tags used and test custom dashboards

##### What you need to do
* Clone the repository
* Add a `./snmp/.env` file then add `DD_API_KEY=<YOUR_API_KEY_HERE>`
* Add a `snmp.d/conf.yaml` file
  * Can test individual instances or auto-discovery by using the `network_address:` key
* Add custom SNMP profile
* Place your `snmpwalk` output in the repo's `/conversion` directory (must be saved with the `.txt` file extension)
* **Run `python3 menu.py` to start using `NDM`/`NPM`**



## Instructions

Simply clone the repo, add your custom SNMP profile to test along with `conf.yaml` file to test it against.

* Custom profile to be tested must be named `test_profile.yaml` and configuration file named `conf.yaml`
* Both `test_profile.yaml` and `conf.yaml` must be placed in the `/snmp/dd_configs` directory of this repo for this program to run properly
* The Datadog agent will only collect metrics that are defined in a profile, also if the `OID` isn't in the `.snmprec` file, it won't be collected by Datadog

This script requires a `.env` file to be placed in the `snmp/` directory for `docker-compose` to read it. Your `.env` file should contain environmental variables needed for your docker containers, in this case your `DD_API_KEY`. The rest of the env var can be added in the `docker-compose.yaml` file.

If you don't already have a `.env` file, you can create one by running the command below in the `snmp` directory :
```
nano .env
```
You can then add the necessary environment variables as depicted below:

`DD_API_KEY= <YOUR_API_KEY_HERE>`


### To start the main CLI menu

Run the following command from the terminal in the main repo directory:

```
python3 menu.py
```

This will bring up the main project menu which allows you to build, run and delete this sandbox

![Image 2023-07-13 at 9 42 04 PM](https://github.com/UTXOnly/SNMP_sandbox/assets/49233513/7aee25f8-0f49-409d-9397-112d0059b0b0)





# Demonstration
## Creating snmprec file and loading snmp config into Datadog agent
![Screen Recording 2023-04-28 at 08 24 41 PM](https://user-images.githubusercontent.com/49233513/235273010-c4dc5101-7900-4620-8b76-a3725ea76579.gif)

## Starting SNMP and Datadog agent containers, collecting tcpdump and running manual debug check


![Screen Recording 2023-04-29 at 03 19 58 PM](https://user-images.githubusercontent.com/49233513/235320574-5582d615-f4e1-479b-979f-d17bd922d67e.gif)

## Analyzing tcpdump and manual debug check output

![Screen Recording 2023-04-29 at 03 44 07 PM (1)](https://user-images.githubusercontent.com/49233513/235321608-38efaa1e-99a7-42d1-a81f-79f3cc3ad881.gif)


### Visual diagram of how this program functions
    
![SNMP containers (2) png 2023-04-26 at 10 22 46 PM](https://user-images.githubusercontent.com/49233513/234743635-0f24b7f1-3e41-4793-97f2-80421a0d26ce.jpg)



# TCPDUMP and Manual SNMP check
* TCPDUMP and manual SNMP check will be placed in the `./snmp/tcpdump` directory
  * You will be prompted at the end of the run script if you would like to open the `.pcap` file in Wireshark, if you do not have it installed, the script will install it for you and open up the new `.pcap` file for your review.




[In the Datadog NDM panel](https://a.cl.ly/GGuzwKje)
![In the Datadog NDM panel](https://user-images.githubusercontent.com/49233513/198861534-cd973b7e-c0a2-4d33-9fec-2fd5c30351d8.gif)




![NPM Map](https://user-images.githubusercontent.com/49233513/208335074-17b407ab-1f21-4334-ac2e-57c9912cee0d.gif)




## Comparing OID configured in custom profile to snmpwalk
You can select option 4 on the menu to compare the oid configured in your custom profile to the snmpwalk output you have loaded to easily identify OID that were configured in the profile but are not present in the snmpwalk.

![Image 2023-07-13 at 9 48 01 PM](https://github.com/UTXOnly/SNMP_sandbox/assets/49233513/258e2c31-f673-4156-9387-79ae61f6e1d7)



## Configuration Notes

* Program will create mock SNMP device containers for each `ip_address:` and first `network_address:` key detected in `conf.yaml`

    * There is only 1 auto-discovery instance created from `network_address:` key as it is not feasible to test more than one auto-discovery subnet at a time

* `conf.yaml` should match what is shown in [example config file](https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/conf.yaml.example)

* For now you will manually need to add ip addresses to your `instances` in your `.conf.yaml` file to an address within the `172.20.0.0/16` subnet. The program also loads the `test_profile.yaml` configuration file to the `/etc/datadog-agent/conf.d/snmp.d/profiles` directory.
* Filename for custom profile to test must be `test_profile.yaml` for the program to work properly

* Below is the example `conf.yaml` file included in this repo, this will work right out of the box.
```
init_config:
  loader: core
  use_device_id_as_hostname: true
  profiles:
    custom-profile:
      definition_file: test_profile.yaml
      
instances:

- ip_address: 192.168.1.123
  snmp_version: 2
  profile: custom-profile
  loader: core
  community_string: 'mocksnmp'
  use_device_id_as_hostname: true
  ```
  


##### Community String Usage for SNMP v2
* The key for `community_string` needs to match the name of the `.snmprec` file that is used to mimic the networking device, be sure to enclose in single quotes `'`



Just run the program and the data will start showing up in the Datadog UI.


## To connect to the running Datadog container

```
docker exec -it datadog-agent /bin/bash
```

## Resources
The Datadog documentation is a great place to start for more information on configuring your `conf.yaml` and custom profile. I would recomend exploring the following documentation as a starting point:
* [What is SNMP?](https://www.datadoghq.com/knowledge-center/network-monitoring/snmp-monitoring/?_gl=1*nisasa*_ga*MTkzODU0NDQ4Ni4xNjUyNzUwNzc2*_ga_KN80RDFSQK*MTY2NzE1ODM4OC42ODMuMS4xNjY3MTU4NDAwLjQ4LjAuMA..)
* [SNMP Metrics](https://docs.datadoghq.com/network_monitoring/devices/snmp_metrics?tab=snmpv2)
* [NDM Profiles](https://docs.datadoghq.com/network_monitoring/devices/profiles)
* [Build a NDM Profile](https://docs.datadoghq.com/network_monitoring/devices/guide/build-ndm-profile/)

Please use example [snmp.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/conf.yaml.example) file for refernce. Proper YAML format is required for the `snmp` check to load in the Datadog agent. You can use a [YAML parser](https://yaml-online-parser.appspot.com/) to validate the yaml format of your configuration files.

Please use [SNMP profiles](https://github.com/DataDog/integrations-core/tree/master/snmp/datadog_checks/snmp/data/profiles) as starting point for creating a custom profile. When creating a custom profile, I recommend extending some of the existing generic profiles to configure device metadata and non-vendor specific `OID`s.

Below is an example of how to extend base profiles at the begining of your custom profile:
```
extends:
  - _base.yaml
  - _generic-if.yaml
  - _generic-ip.yaml
  - _generic-tcp.yaml
  - _generic-udp.yaml
  - _generic-bgp4.yaml
  - _generic-ospf.yaml
  ```
  ##### Syntax Notes
  The SNMP integration can collect both scalar and tabular SNMP objects and have differnt syntax within your custom profile for each type.
  
  * An example of syntax used for tabular objects:

```
metrics:
  - MIB: MERAKI-CLOUD-CONTROLLER-MIB
    table:
      OID: 1.3.6.1.4.1.29671.1.1.4
      name: devTable
      # devTable INDEX is: devMac
    forced_type: gauge
    symbols:
      - OID: 1.3.6.1.4.1.29671.1.1.4.1.3
        name: devStatus
      - OID: 1.3.6.1.4.1.29671.1.1.4.1.5
        name: devClientCount
    metric_tags:
      # devMac is part of the devTable index
      - column:
          OID: 1.3.6.1.4.1.29671.1.1.4.1.1
          name: devMac
          format: mac_address
        tag: mac_address
      - column:
          OID: 1.3.6.1.4.1.29671.1.1.4.1.2
          name: devName
        tag: device
      - column:
          OID: 1.3.6.1.4.1.29671.1.1.4.1.9
          name: devProductCode
        tag: product
```
   * An example of syntax used for scalar objects:
        
   ```
     metrics:
      - OID: 1.3.6.1.2.1.6.0
        name: tcpActiveOpens # what to use in the metric name; can be anything
  ```


## To Do
- [ ] Add functionality for SNMP `v3` 
- [ ] Add SNMP trap functionality
- [ ] Automatically assign ip addresses and snmp profiles if not using single snmprec
- [ ] Change `run.sh` script for converting MIB to snmprec to a python script, add to main menu
- [X] Add autodiscovery functionality
- [X] Create conversion program to translate `snmpwalk` output to `.snmprec` format

  

