def extract_oid_values(file_path):
    oid_values = []
    with open(file_path, 'r') as file:
        for line in file:
            if 'OID:' in line:
                oid_value = line.split('OID:')[1].strip()
                oid_values.append(oid_value)
    return oid_values

def check_oid_presence(file_path, oid_values):
    present_oids = []
    with open(file_path, 'r') as file:
        file_contents = file.read()
        for oid_value in oid_values:
            if oid_value not in file_contents:
                present_oids.append(oid_value)
    return present_oids

# Read the configuration file containing the data
config_file_path = './snmp/dd_config_files/test_profile.yaml'

# Extract the OID values
oid_values = extract_oid_values(config_file_path)

# Read the file to check presence
presence_file_path = './snmp/data/mocksnmp.snmprec'

# Check for presence of OID values
present_oids = check_oid_presence(presence_file_path, oid_values)

def print_color(text, color):
    print(f"\033[1;{color}m{text}\033[0m", end="")

# Print the present OID values
for oid_value in present_oids:
    print_color("The following OID was present in your test profile but not your snmpwalk output: ", 31)
    print(oid_value)

