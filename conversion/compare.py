import re
test_profile = open ("../snmp/dd_config_files/full_profile.yaml", "r")
snmprec_file = open ("../snmp/data/mocksnmp.snmprec", "r")
profile_lines = []
snmprec_lines = []
i = 0 
for profile in test_profile:
    if re.search('OID', profile):
        #print(profile)
        profile_lines.append(profile)

for line in snmprec_file:
    snmprec_lines.append(str(line.partition("|")[0]))

for line in profile_lines:
    stripped = str(line.partition(":")[2])
    print(stripped)
    if stripped in snmprec_lines:
        i += 1

print(i)
