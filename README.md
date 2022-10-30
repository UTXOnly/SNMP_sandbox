# SNMP_sandbox
A sandbox environment for testing custom SNMP profiles for use with Datadog Network Device Management. By adding your own Datadog API key to an `.env` file and then running a simple run command, you can validate your custom SNMP profile with the help of a mock SNMP device running in another Docker container.

##### Use Case
To validate a custom SNMP profile along with Datadog agent configuration.

## How to Use
This script requires a `.env` file to be placed in the repository's parent directory (./). Your `.env` file should contain environmental variables needs for your docker containers, in this case your `DD_API_KEY` and `DD_AGENT_HOST`

If you don't already have a `.env` file, you can create one by running the command below in this repository's parent directory (./):

`touch .env`

You can then add the necessary environment variables as depicted below:

`DD_API_KEY= <YOUR_API_KEY_HERE>`

To run this script, simply run the follwing script from this repository's parent directory(`SNMP_sandbox`).

`./run.sh`

The run script simply builds fresh Docker images each instance, leveraging the docker-compose command


## Configuration Notes

`conf.yaml` should match what is shown in [example config file](https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/conf.yaml.example)

* The program will automatically correct the value corresponding to the `ip_address:` key to `host.docker.internal`. The program aslo loads the `_test_profile.yaml` configuration file to the `/etc/datadog-agent/conf.d/snmp.d/profiles` directory.
* Filename for custom profile to test must be `_test_profile.yaml` for the program to work properly


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
  community_string: 'mockSNMP'
  use_device_id_as_hostname: true
  ```
  


##### Community String Usage for SNMP v2
* The key for `community_string` needs to match the name of the `.snmprec` file that is used to mimic the networking device, be sure to enclose in single quotes `'`



Just run the program and the data will start showing up in the Datadog UI.


## To connect to the running Datadog container

```
docker exec -it datadog-agent /bin/bash
```
  

