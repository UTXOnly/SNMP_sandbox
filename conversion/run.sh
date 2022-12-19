#!/bin/bash

#Download MIB table, remove the first line containing "---", output to file_to_analyize.yaml

curl https://bestmonitoringtools.com/mibdb/mibs_csv/${1}.csv | tail -n +1 > ./csv+snmprec/file_to_analyize.csv
wait

mib_name=$1
echo $mib_name
export mib_name

python3 ./convert_csv/csv_to_objects.py
