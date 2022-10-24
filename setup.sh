source /home/vagrant/.sandbox.conf.sh


#for file in ./vagrant/*;
 # do
  #    source $file;
 #done

echo api key ${DD_API_KEY}
echo "Installing Datadog Agent 7 from api_key: ${DD_API_KEY} but not starting it yet"

DD_INSTALL_ONLY=true DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${DD_API_KEY} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
echo "Update apt-get"
sudo apt-get update

echo "Fix lang issue... + export LC_ALL so we don't have to logout/login"

echo 'LC_ALL=en_US.UTF-8'| sudo tee -a /etc/default/locale
export LC_ALL=en_US.UTF-8

#PATH_TO_SNMP=<


#CONF_SNMP=

echo "Set log level of the datadog agent to TRACE"
echo 'log_level: trace'| sudo tee -a /etc/datadog-agent/datadog.yaml
echo 'dogstatsd_non_local_traffic: true' | sudo tee -a /etc/datadog-agent/datadog.yaml
echo 'logs_enabled: true' | sudo tee -a /etc/datadog-agent/datadog.yaml
echo "Adding custom SNMP profile"
touch /etc/datadog-agent/conf.d/snmp.d/profiles/test_profile.yaml
touch /etc/datadog-agent/conf.d/snmp.d/conf.yaml
#echo ${PATH_TO_SNMP} | sudo tee -a /etc/datadog-agent/conf.d/snmp.d/profiles/custom_profile.yaml
#echo ${CONF_SNMP} | sudo tee -a touch /etc/datadog-agent/conf.d/snmp.d/conf.yaml
FILE1=/etc/datadog-agent/conf.d/snmp.d/conf.yaml
if [ -f "$FILE1" ]; then
    echo "file exists"
else 
    touch "$FILE1"
fi

FILE2=/etc/datadog-agent/conf.d/snmp.d/profiles/test_profile.yaml
if [ -f "$FILE2" ]; then
    echo "file exists"
else 
    touch "$FILE2"
fi

cat /home/vagrant/test_profile.yaml | sudo tee /etc/datadog-agent/conf.d/snmp.d/profiles/test_profile.yaml
sudo chown dd-agent:dd-agent /etc/datadog-agent/conf.d/snmp.d/profiles/test_profile.yaml
#sudo tee >/etc/datadog-agent/conf.d/snmp.d/conf.yaml 

cat /home/vagrant/conf.yaml | sudo tee /etc/datadog-agent/conf.d/snmp.d/conf.yaml
sudo chown dd-agent:dd-agent /etc/datadog-agent/conf.d/snmp.d/conf.yaml

echo "Start Datadog agent"
#sudo systemctl start datadog-agent
sudo service datadog-agent start