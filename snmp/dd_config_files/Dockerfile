FROM datadog/agent:latest
COPY ./conf.yaml /etc/datadog-agent/conf.d/snmp.d/
COPY ./test_profile.yaml /etc/datadog-agent/conf.d/snmp.d/profiles/
RUN apt-get update -y &&\
    apt-get install -y tcpdump