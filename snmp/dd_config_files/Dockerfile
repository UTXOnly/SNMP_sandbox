FROM datadog/agent:latest
COPY ./conf.yaml /etc/datadog-agent/conf.d/snmp.d/
COPY ./_test_profile.yaml /etc/datadog-agent/conf.d/snmp.d/profiles/
#RUN bash cat ./dd_config_files/datadog.yaml | tee -a /etc/datadog-agent/datadog.yaml
RUN apt-get update -y &&\
    apt-get install -y tcpdump