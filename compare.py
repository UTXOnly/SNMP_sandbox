import re
BRed='\033[1;31m'
BGreen='\033[1;32m'
BBlue='\033[34;1m'
NC='\033[0m' 
test_profile = open ("./snmp/dd_config_files/_test_profile.yaml", "r")
snmprec_file = open ("./snmp/data/mocksnmp.snmprec", "r")
profile_lines = []
snmprec_lines = []
oid_in_profile = 0 
oid_not_in_profile = 0
for line in test_profile:
    if re.search('OID', line):
        profile_lines.append(line)
        oid_in_profile += 1

for line in snmprec_file:
    snmprec_lines.append(line.partition("|")[0].strip())

for line in profile_lines:
    stripped = line.partition(":")[2].strip()
    if stripped in snmprec_lines:
        oid_not_in_profile += 1
        print(stripped)

print(f"{BBlue}\nThere were {NC}", oid_in_profile, f"{BBlue} OIDs configured in your profile{NC}\n", oid_not_in_profile,  f"{BBlue} OID's from your profile were not detected in your snmprec file{NC}")
