import subprocess

import os
import re

import glob
import re

def print_color(text, color):
    print(f"\033[1;{color}m{text}\033[0m")



log_files = glob.glob("./snmp/tcpdump/*.log")
oid_set = set()


log_dir_path = "./snmp/tcpdump/"
log_files = [os.path.join(log_dir_path, f) for f in os.listdir(log_dir_path) if f.endswith(".log")]

oid_pattern = r"value for Scalar OID `((?:\d+\.)*\d+)`"

oids_set = set()  
for log_file in log_files:
    with open(log_file) as f:
        for line in f:
            match = re.search(oid_pattern, line)
            if match:
                oid_str = match.group(1)
                # Split the string into a list of OID elements and join them back together with periods
                oid_list = oid_str.split(".")
                oid_str_with_periods = ".".join(oid_list)
                oids_set.add(oid_str_with_periods)  # add the matching OID to the set of found unique OIDs

if len(oids_set) > 0:
    oid_list = sorted(list(oids_set))  # convert the set back to a list and sort it

else:
    print(f"No OIDs match the pattern '{oid_pattern}' in the log files under {log_dir_path}")


snmprec_file = "./snmp/data/mocksnmp.snmprec"

def check_variables_in_file(oid_list):
    file_path = "./snmp/data/mocksnmp.snmprec"

    with open(file_path) as f:
        contents = f.read()
        print("##############################################################\n")
        found_oids = set()
        for variable in oid_list:
            if variable in contents:
                found_oids.add(variable)
            else:
                oid_elements = variable.split(".")
                # Remove the first element (the SNMP prefix) from the OID elements list
                oid_without_prefix = ".".join(oid_elements[1:])
                if oid_without_prefix in contents:
                    print(f"\033[32m{variable} is not present in the snmprec file, but {oid_without_prefix} is present.\033[0m")
                else:
                    print(f"\033[32m{variable} Was configured in your profile but was not collected by the Datadog agent which is expected as the OID is not present in the snmprec file\033[0m")

        for found_oid in found_oids:
            print(f"\033[31m{found_oid} was configured in your profile, is also present in the snmprec file, but was not collected by the Datadog agent. Your profile needs to be adjusted\033[0m")

output = check_variables_in_file(oid_list)



