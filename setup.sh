source /~/vagrant/.sandbox.conf.sh

$1 = PATH_TO_SNMP
$2 = CONF_SNMP
echo api key ${DD_API_KEY}
echo "Installing Datadog Agent 7 from api_key: ${DD_API_KEY} but not starting it yet"

DD_INSTALL_ONLY=true DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${DD_API_KEY}  bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"

echo "Update apt-get"
sudo apt-get update

echo "Fix lang issue... + export LC_ALL so we don't have to logout/login"

echo 'LC_ALL=en_US.UTF-8'| sudo tee -a /etc/default/locale
export LC_ALL=en_US.UTF-8

echo "Set log level of the datadog agent to TRACE"
echo 'log_level: trace'| sudo tee -a /etc/datadog-agent/datadog.yaml
echo "Adding custom SNMP profile"
cat ${PATH_TO_SNMP} | sudo tee -a /etc/datadog-agent/snmp.d/profiles/custom_profile.yaml
cat ${CONF_SNMP} | sudo tee -a /etc/datadog-agent/snmp.d/conf.yaml




echo "Install maven"
sudo apt install -y maven

echo "Start Datadog agent"
sudo systemctl start datadog-agent
