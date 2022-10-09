source ~/vagrant/.sandbox.conf.sh

#PATH_TO_SNMP="./sample_custom_profile.yaml"
#CONF_SNMP="./conf.yaml"
#DD_API_KEY=
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
#echo 'logs_enabled: true' | sudo tee -a /etc/datadog-agent/datadog.yaml
echo "Adding custom SNMP profile"
touch /etc/datadog-agent/conf.d/snmp.d/profiles/custom_profile.yaml
touch /etc/datadog-agent/conf.d/snmp.d/conf.yaml
#echo ${PATH_TO_SNMP} | sudo tee -a /etc/datadog-agent/conf.d/snmp.d/profiles/custom_profile.yaml
#echo ${CONF_SNMP} | sudo tee -a touch /etc/datadog-agent/conf.d/snmp.d/conf.yaml
sudo tee >/etc/datadog-agent/conf.d/snmp.d/profiles/_custom_profile.yaml <<EOF
extends:
  - _cisco-generic.yaml

metrics:
- MIB: CISCO-IPSEC-FLOW-MONITOR-MI
  forced_type: monotonic_count_and_rate
  symbols:
  - OID: 1.3.6.1.4.1.9.9.171.1.3.2.1.26
    name: cipSecTunInOctets
  - OID: 1.3.6.1.4.1.9.9.171.1.3.2.1.39
    name: cipSecTunOutOctets
  - OID: 1.3.6.1.4.1.9.9.171.1.3.2.1.33
    name: cipSecTunInDropPkts
  - OID: 1.3.6.1.4.1.9.9.171.1.3.2.1.46
    name: cipSecTunOutDropPkts
EOF

sudo tee >/etc/datadog-agent/conf.d/snmp.d/conf.yaml <<EOF  
init_config:


  loader: core

    
  use_device_id_as_hostname: true

    
  profiles:
    custom_test:
      definition_file: custom_profile.yaml
    


instances:

  - ip_address: 192.168.1.153
    snmp_version: 2
    loader: core

    community_string: cisco_asa_5525
    

    
    
EOF



#echo "Install maven"
#sudo apt install -y maven

echo "Start Datadog agent"
#sudo systemctl start datadog-agent
sudo service datadog-agent start