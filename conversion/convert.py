import os
import subprocess
import sys
import platform
import chardet

def convert_snmpwalk(file_path):
    # Detect file encoding and convert to UTF-8
    with open(file_path, 'rb') as file:
        content = file.read()
        result = chardet.detect(content)
        encoding = result['encoding']
        decoded_contents = content.decode(encoding)

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(decoded_contents)

    if platform.system() == "Darwin":
        # Mac branch
        subprocess.run(['sed', '-i', '', 's/^\.//g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.OID:*./|6|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.STRING:*./|4|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.INTEGER:*./|2|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.Counter[ ]*32:*./|65|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.Gauge[ ]*32:*./|66|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.Counter[ ]64:*./|70|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.Hex-STRING:*./|68|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=.IpAddress:*./|64|/g', file_path])
        subprocess.run(['sed', '-i', '', 's/.=./|4|/g', file_path])
    else:
        # Linux or other Unix-like systems branch
        subprocess.run(['sed', '-i', 's/^\.//g', file_path])
        subprocess.run(['sed', '-i', 's/.=.OID:*./|6|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.STRING:*./|4|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.INTEGER:*./|2|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.Counter[ ]*32:*./|65|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.Gauge[ ]*32:*./|66|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.Counter[ ]64:*./|70|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.Hex-STRING:*./|68|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=.IpAddress:*./|64|/g', file_path])
        subprocess.run(['sed', '-i', 's/.=./|4|/g', file_path])


def filter_lines(lines):
    filtered_lines = [line for line in lines if line.startswith("1.3.6") or line.startswith(".1.3.6")]
    return filtered_lines


dir_path = os.getcwd()
print(dir_path)
file_list = [f for f in os.listdir(dir_path) if f.endswith('.txt')]

# Pass each file to convert_snmpwalk function one at a time
for file_path in file_list:
    convert_snmpwalk(file_path)


snmprec_file_path = '../snmp/data/mocksnmp.snmprec'

if not os.path.exists(snmprec_file_path):
    # Create a new file if it doesn't exist
    open(snmprec_file_path, 'a').close()

# Delete the contents of the file
open(snmprec_file_path, 'w').close()
# Pipe converted snmpwalk output into existing snmprec file for ease of use (won't need to change conf.yaml)
with open('../snmp/data/mocksnmp.snmprec', 'a') as target_file:
    for filename in os.listdir('.'):
        if filename.endswith('.txt'):
            with open(filename) as source_file:
                lines = source_file.readlines()
                filtered_lines = filter_lines(lines)
                target_file.writelines(filtered_lines)
                target_file.write('\n')
