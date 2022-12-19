# SNMP_sandbox                                                                                               
                                                                                                        

A sandbox environment for testing custom SNMP profiles with Datadog Network Device Management. By adding your own Datadog API key to an `.env` file, then running a simple run script, you can validate your custom SNMP profile with the help of a mock SNMP device running in another Docker container.

##### Use Case
To validate custom SNMP profiles along with Datadog agent configuration
* Validate `conf.yaml` and `custom_profile` configuration in Datadog agent
* Simulate a SNNP device being polled and reporting metrics to Datadog agent
* Validate tags used and test custom dashboards

##### What you need to do
* Clone the repoistory
* Add a `snmp.d/comf.yaml` file
  * Optionally add `datadog.yanl` file for auto-discovery
* Add custom SNMP profile
* Use `convert.sh` script to create `.snmprec` file if needed
* Use `run.sh` script to run all containers and start using `NDM`/`NPM`

## Instructions

Simply clone the repo, add your custom SNMP profile to test along with `conf.yaml` file to test it against.

* Custom profile to be tested must be named `_test_profile.yaml` and configuration file named `conf.yaml`
* Both `_test_profile.yaml` and `conf.yaml` must be placed in the `/snmp/dd_configs` directory of this repo for this program to run properly
* The Datadog agent will only collect metrics that are defined in a profile, if the `OID` isn't in the `.snmprec` file, it won't be collected by Datadog

This script requires a `.env` file to be placed in the `snmp/` directory for `docker-compose` to read it. Your `.env` file should contain environmental variables needed for your docker containers, in this case your `DD_API_KEY`. The rest of the env var can be added in the `docker-compose.yaml` file.

If you don't already have a `.env` file, you can create one by running the command below in the `snmp` directory :
```
nano .env
```
You can then add the necessary environment variables as depicted below:

`DD_API_KEY= <YOUR_API_KEY_HERE>`

##### File Placement

![run sh — SNMP_sandbox 2022-11-28 at 10 56 22 PM](https://user-images.githubusercontent.com/49233513/204435564-8422ad77-758e-4805-acfc-01f65de1b28c.jpg)



To run this script, simply run the follwing script from this repository's main directory(`SNMP_sandbox`).
```
./run.sh
```
The run script builds fresh Docker images at runtime, leveraging the docker-compose command to run these containers togehter.

##### To stop the containers and destroy the Docker network and images created run the below command:
```
./destroy.sh
```

# Demonstration
* Commands used to clone repo and move configuration files into the appropriate directories.
  * `git clone git@github.com:UTXOnly/SNMP_sandbox.git`
    *  This will clone the repo and create a new folder `SNMP_sandbox` , `run` and `destroy` commands are run from here
  * `cp <Filepath_to_conf.yaml>/conf.yaml ./snmp/dd_configs.conf.yaml`
    * When run from the `SNMP_sandbox` directory, copies configuration file to appropriate directory
  * `cp <Filepath_to_test_profile.yaml>/conf.yaml ./snmp/dd_configs/_test_profile.yaml`
    * When run from the `SNMP_sandbox` directory, copies custom profile to appropriate directory 
# TCPDUMP and Manual SNMP check
* TCPDUMP and manual SNMP check will be placed in the `./snmp/tcpdump` directory
  * You will be prompted at the end of the run script if you would like to open the `.pcap` file in Wireshark, if you do not have it installed, the script will install it for you and open up the new `.pcap` file for your review.







https://user-images.githubusercontent.com/49233513/204659435-33a6e04f-2f6b-4b52-895b-9bd242b2b44b.mp4







[In the Datadog NDM panel](https://a.cl.ly/GGuzwKje)
![In the Datadog NDM panel](https://user-images.githubusercontent.com/49233513/198861534-cd973b7e-c0a2-4d33-9fec-2fd5c30351d8.gif)




![NPM Map](https://user-images.githubusercontent.com/49233513/208335074-17b407ab-1f21-4334-ac2e-57c9912cee0d.gif)







## Configuration Notes

`conf.yaml` should match what is shown in [example config file](https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/conf.yaml.example)

* For now you will manually need to add ip addresses to your `instances` in your `.conf.yaml` file to an address within the `172.20.0.0/16` subnet. The program also loads the `_test_profile.yaml` configuration file to the `/etc/datadog-agent/conf.d/snmp.d/profiles` directory.
* Filename for custom profile to test must be `_test_profile.yaml` for the program to work properly

* Below is the example `conf.yaml` file included in this repo, this will work right out of the box.
```
init_config:
  loader: core
  use_device_id_as_hostname: true
  profiles:
    custom-profile:
      definition_file: _test_profile.yaml
      
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
  
  ##### How to create your own snmprec files
* From the `conversion` directory, run the `convert.sh` script
* You will be prompted to enter a `MIB` name. Please select any available MIB on [Best Monitoring Tools](https://bestmonitoringtools.com/mibdb/mibdb_search.php)
* A script will convert the `MIB` file and appened it to an exisiting `mocksnmp.snmprec` file within the appropriate appropriate `data` directory
* You can now run the `run.sh` script from the main repo directory `SNMP-sandbox`


## To Do
* Add functionality for SNMP `v3` 
* Create conversion program to translate `snmpwalk` output to `.snmprec` format
  * Thinking of a mix of `BASH` and `Python` scripts possibly???
  

