#!/usr/bin/env python3
import os
import datetime

os.system('source ./snmp/.env')

BRed = '\033[1;31m'
BGreen = '\033[1;32m'
NC = '\033[0m'  # No Color

os.system('python3 parse_conf.py')

os.chdir('snmp')

print(f"{BGreen}##################### Creating docker network############################{NC}")

# create docker network
os.system('docker network create static-network')

print(f"{BGreen}################# Building docker image##############################{NC}")

# build docker image
os.system('docker-compose up --build --force-recreate -d') # Add the -d flag to run container in detached mode

print(f"{BRed}\nDocker up{NC}")

print(f"{BGreen}\n################## TCPDUMP started, please wait 30 seconds "
      f"#######################################\n{BRed}")

timestamp = datetime.datetime.now().strftime('%m-%d-%Y')

# Starting a tcpdump filtering traffic on port 161 to closer inspect 
os.system(f'docker exec datadog-agent tcpdump -T snmp -c 30 '
          f'-w /tcpdumps/dump{timestamp}.pcap')

print(f"{NC}\nWriting output of check to ./tcpdump/dump_{timestamp}.pcap")

#print(f"{BGreen}\nRunning comparison of OID's configured in profile to OID in snmprec{NC}")
#print(f"{BRed}\nThe following OID's in your snmp profile were configured\n{NC}")
os.chdir('..')
#os.system('python3 compare.py')

print(f"{BGreen}\n################### Running SNMP check ####################################{NC}")
print(f"{BRed}\nWriting output of check to ./tcpdump/debug_snmp_check.log{NC}")
os.chdir('snmp')

# Run DEBUG level SNMP check, out put to file locally
os.system("docker exec datadog-agent bash -c 'agent check snmp -l debug > /tcpdumps/debug_snmp_check.log'")

print(f"{BGreen}\nDo you want to open the .pcap file in Wireshark now? (y|n){NC}?")
read_answer = input().lower()
if read_answer in ('yes', 'y'):
    system_name = os.uname().sysname

    if system_name == 'Darwin':
        # Mac branch
        if os.path.isdir('/Applications/Wireshark.app'):
            os.system(f'open -n -a /Applications/Wireshark.app ./tcpdump/dump{timestamp}.pcap')
            os.system('open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap')
        else:
            os.system('brew install wireshark')
            os.system('open -n -a /Applications/Wireshark.app ./tcpdump/*.pcap')
    elif system_name.startswith('Linux'):
        # Linux branch
        if os.path.isdir('/etc/wireshark'):
            os.system(f'wireshark "./tcpdump/dump{timestamp}.pcap"')
        else:
            os.system('sudo apt install wireguard -y')
            os.system(f'wireshark ./tcpdump/dump{timestamp}.pcap')
else:
    print(f"{BGreen}Skipping Wireshark{NC}")

