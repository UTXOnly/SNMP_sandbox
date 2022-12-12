FROM python:3.7-slim
RUN pip install snmpsim
RUN adduser --system snmpsim
#ADD data /usr/local/share/snmpsim/data
#RUN chown snmpsim /usr/local/share/snmpsim/data --agent-udpv4-endpoint=0.0.0.0:161
CMD snmpsimd.py --agent-udpv4-endpoint=0.0.0.0:161 --data-dir=/usr/local/share/snmpsim/data --process-user=root --process-group=nogroup