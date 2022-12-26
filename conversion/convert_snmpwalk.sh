#!/bin/bash
#echo "Enter file name you want to convert to snmprec file"
#read snmp_file
#Determine if mac or linux, convert snmpwalk syntax into snmprec syntax
if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
    sed -i '' "s/^\.//g" ./*.txt
    sed -i '' "s/.=.OID:*./|6|/g" ./*.txt
    sed -i '' "s/.=.STRING:*./|4|/g" ./*.txt
    sed -i '' "s/.= INTEGER:*./|2|/g" ./*.txt
    sed -i '' "s/.= Counter32:*./|65|/g" ./*.txt
    sed -i '' "s/.= Gauge32:*./|66|/g" ./*.txt
    sed -i '' "s/.= Counter64:*./|70|/g" ./*.txt
    sed -i '' "s/.= Hex-STRING:*./|68|/g" ./*.txt
    sed -i '' "s/.= IpAddress:*./|64|/g" ./*.txt
    sed -i '' "s/.=./|4|/g" ./*.txt
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Linux branch
    sed "s/^\.//g" -i ./*.txt
    sed "s/.=.OID:*./|6|/g" -i ./*.txt
    sed "s/.=.STRING:*./|4|/g" -i ./*.txt
    sed "s/.= INTEGER:*./|2|/g" -i ./*.txt
    sed "s/.= Counter32:*./|65|/g" -i ./*.txt
    sed "s/.= Gauge32:*./|66|/g" -i ./*.txt
    sed "s/.= Counter64:*./|70|/g" -i ./*.txt
    sed "s/.= Hex-STRING:*./|68|/g" -i ./*.txt
    sed "s/.= IpAddress:*./|64|/g" -i ./*.txt
    sed "s/.=./|4|/g" -i ./*.txt
else
    echo -e "${BRed}\nUnable to detect OS...skipping sed substituion${NC}"
fi