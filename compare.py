import re
BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' 
test_profile = open ("./snmp/dd_config_files/full_profile.yaml", "r")
snmprec_file = open ("./snmp/data/mocksnmp.snmprec", "r")
profile_lines = []
snmprec_lines = []
i = 0 
ii = 0
for line in test_profile:
    if re.search('OID', line):
        profile_lines.append(line)

for line in snmprec_file:
    snmprec_lines.append(line.partition("|")[0].strip())

for line in profile_lines:
    stripped = line.partition(":")[2].strip()
    if stripped in snmprec_lines:
        i += 1
        print(stripped)

print(f"{BRed}\nThere were {NC}", i, f"{BRed} OIDs configured in your profile{NC}\n", ii,  f"{BRed} OID's from your profile were not detected in your snmprec file{NC}")