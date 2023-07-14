import os

# docker-compose down with remove-orphans
os.system("docker-compose down --remove-orphans")

# stop all running containers
os.system("docker stop $(docker ps -a -q)")

# remove all the containers
os.system("docker rm $(docker ps -a -q) -f")

# remove all the images
os.system("docker rmi $(docker image ls -a -q) -f")

# remove directories
os.system("sudo rm -r ./snmp/tcpdump")
os.system("sudo rm -r ./parsed_yaml")
os.system("sudo rm -r ./snmp/data/mocksnmp.snmprec")

# OS specific commands to modify files
if os.name == 'posix':
    if os.uname().sysname == 'Darwin': # macOS
        os.system("sed -E -i '' '37,$d' ./snmp/docker-compose.yaml")
        os.system("sed -E -i '' '2808,$d' ./snmp/data/mocksnmp.snmprec")
    elif os.uname().sysname == 'Linux': # Linux
        os.system("sed -i '37,$d' ./snmp/docker-compose.yaml")
        os.system("sed -i '2808,$d' ./snmp/data/mocksnmp.snmprec")
else:
    print("\nUnable to detect OS...skipping sed substitution\n")
