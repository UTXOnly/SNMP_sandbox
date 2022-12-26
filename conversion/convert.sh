#!/bin/bash

BRed='\033[1;31m'
BGreen='\033[1;32m'
BBlue='\u001b[34m'
NC='\033[0m' # No Color

echo -e "${BGreen}Would you like to convert snmpwalk output to snmprec?\n${NC}"
read snmprec_ans

function convert_snmpwalk (){
    if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
        sed -i '' "s/^\.//g" $1
        sed -i '' "s/.=.OID:*./|6|/g" $1
        sed -i '' "s/.=.STRING:*./|4|/g" $1
        sed -i '' "s/.= INTEGER:*./|2|/g" $1
        sed -i '' "s/.= Counter32:*./|65|/g" $1
        sed -i '' "s/.= Gauge32:*./|66|/g" $1
        sed -i '' "s/.= Counter64:*./|70|/g" $1
        sed -i '' "s/.= Hex-STRING:*./|68|/g" $1
        sed -i '' "s/.= IpAddress:*./|64|/g" $1
        sed -i '' "s/.=./|4|/g" $1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Linux branch
        sed "s/^\.//g" -i $1
        sed "s/.=.OID:*./|6|/g" -i $1
        sed "s/.=.STRING:*./|4|/g" -i $1
        sed "s/.= INTEGER:*./|2|/g" -i $1
        sed "s/.= Counter32:*./|65|/g" -i $1
        sed "s/.= Gauge32:*./|66|/g" -i $1
        sed "s/.= Counter64:*./|70|/g" -i $1
        sed "s/.= Hex-STRING:*./|68|/g" -i $1
        sed "s/.= IpAddress:*./|64|/g" -i $1
        sed "s/.=./|4|/g" -i $1
    else
        echo -e "${BRed}\nUnable to detect OS...skipping sed substituion${NC}"
    fi
}
if [[ $snmprec_ans == "yes" || $snmprec_ans == "y" ]]; then
    echo "Please place snmpwalkoutput in this directory and add .txt extension if needed"
    convert_snmpwalk "./*.txt"
else
    echo -e "${BGreen}Moving on...${NC}"
fi

echo -e "${BGreen}Please enter the MIB name you would like to convert:\n${NC}"
read MIB_NAME
#sed "s/$/${MIB_NAME}/" -i .env

cd ./MIB_to_SNMPrec
./run.sh ${MIB_NAME}
#Pipe MIB output, appenend into data/snmprec file
cat ./csv+snmprec/MIB.snmprec | tee -a ../../snmp/data/mocksnmp.snmprec
#Remove uneeded MIB file, change back to snmp/data
rm ./csv+snmprec/MIB.snmprec
cd ../../snmp/data/


if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
        #Replace sysDescr values
        sed -i '' 's/.*1.3.6.1.2.1.1.1.0.*/1.3.6.1.2.1.1.1.0|4|Test_SNMP/' mocksnmp.snmprec
        #Replace sysName values
        sed -i '' 's/.*1.3.6.1.2.1.1.5.0.*/1.3.6.1.2.1.1.5.0|4|Test_SNMP device/' mocksnmp.snmprec
        #Replace sysLocation values
        sed -i '' 's/.*1.3.6.1.2.1.1.6.0.*/1.3.6.1.2.1.1.6.0|4|Boston, MA/' mocksnmp.snmprec    
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Linux branch
        #Replace sysDescr values
        sed '/^1.3.6.1.2.1.1.1.0*/c\1.3.6.1.2.1.1.1.0|4|Test_SNMP' -i mocksnmp.snmprec
        #Replace sysName values
        sed '/^1.3.6.1.2.1.1.5.0*/c\1.3.6.1.2.1.1.5.0|4|Test_SNMP device' -i mocksnmp.snmprec
        #Replace sysLocation values
        sed '/^1.3.6.1.2.1.1.6.0*/c\1.3.6.1.2.1.1.6.0|4|Boston, MA' -i mocksnmp.snmprec
else
    echo -e "${BRed}\nUnable to detect OS...skipping sed substituion${NC}"
fi
