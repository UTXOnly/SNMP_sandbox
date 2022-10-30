# SNMP_sandbox
A sandbox environment for testing custom SNMP profiles for use with Datadog Network Device Management. By adding your own Datadog API key to an `.env` file and then running a simple run command, you can validate your custom SNMP profile with the help of a mock SNMP device running in another Docker container.

### Use Case
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


