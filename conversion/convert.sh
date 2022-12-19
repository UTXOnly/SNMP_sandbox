#!/bin/bash

BRed='\033[1;31m'
BGreen='\033[1;32m'
BBlue='\u001b[34m'
NC='\033[0m' # No Color

echo -e "${BGreen}Please enter the MIB name you would like to convert:\n${NC}"
read MIB_NAME
#sed "s/$/${MIB_NAME}/" -i .env

cd ./MIB_to_SNMPrec
./run.sh ${MIB_NAME}


echo $(pwd)
cat ./csv+snmprec/MIB.snmprec | tee -a ../../snmp/data/mocksnmp.snmprec
rm ./csv+snmprec/MIB.snmprec
cd ../../snmp/data/


if [ "$(uname)" == "Darwin" ]; then
    #Mac branch
        #Replace sysDescr values
        sed sed -r -i '' '/^1.3.6.1.2.1.1.1.0*/c\1.3.6.1.2.1.1.1.0|4|Test_SNMP' mocksnmp.snmprec
        #Replace sysName values
        sed sed -r -i '' '/^1.3.6.1.2.1.1.5.0*/c\1.3.6.1.2.1.1.5.0|4|Test_SNMP device' mocksnmp.snmprec
        #Replace sysLocation values
        sed sed -r -i '' '/^1.3.6.1.2.1.1.6.0*/c\1.3.6.1.2.1.1.6.0|4|Boston, MA' mocksnmp.snmprec   
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