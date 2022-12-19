import random

def create_snmp_rec(list_to_scan):
    data_type = [2,4,5,6,64,65,66,67,68,70]
    snmprec_to_export = open("./csv+snmprec/MIB.snmprec", "w")
    for row in list_to_scan:
        metric_value = random.randint(1,22)
        string_value = random.choice(['Cisco', 'Juniper', 'Sophos'])
        other_string_value = random.choice(['UP', 'DOWN', 'OK'])
        truth_value = random.choice(['TRUE', 'FALSE'])
        time_ticks = random.randint(999999,197740964)
        if row.data_type == "integer32" : 
            integer_32 = str(row.oid) + "|" + str(data_type[0]) + "|" + str(metric_value)
            snmprec_to_export.write(integer_32+"\n")
        elif row.data_type == "gauge32":
            gauge_32 = str(row.oid) + "|" + str(data_type[6]) + "|" + str(metric_value)
            snmprec_to_export.write(gauge_32+"\n")
        elif row.data_type == "counter32":
            counter_32 = str(row.oid) + "|" + str(data_type[5]) + "|" + str(string_value)
            snmprec_to_export.write(counter_32+"\n")
        elif row.data_type == "physaddress":
            physaddress = str(row.oid) + "|" + str(data_type[1]) + "|" + str("00:00:5e:00:53:af")
            snmprec_to_export.write(physaddress+"\n")
        elif row.data_type == "integer":
            integer = str(row.oid) + "|" + str(data_type[0]) + "|" + str(metric_value)
            snmprec_to_export.write(integer+"\n")
        elif row.data_type == "counter64":
            counter_64 = str(row.oid) + "|" + str(data_type[9]) + "|" + str(other_string_value)
            snmprec_to_export.write(counter_64+"\n")
        elif row.data_type == "truthvalue":
            truthvalue = str(row.oid) + "|" + str(data_type[1]) + "|" + str(truth_value)
            snmprec_to_export.write(truthvalue+"\n")
        elif row.data_type == "displaystring":
            displaystring = str(row.oid) + "|" + str(data_type[1]) + "|" + str(other_string_value)
            snmprec_to_export.write(displaystring+"\n")
        elif row.data_type == "timeticks":
            timeticks = str(row.oid) + "|" + str(data_type[7]) + "|" + str(time_ticks)
            snmprec_to_export.write(timeticks+"\n")
        elif row.data_type == "displaystring":
            displaystring = str(row.oid) + "|" + str(data_type[1]) + "|" + str(string_value)
            snmprec_to_export.write(displaystring+"\n")
    snmprec_to_export.close()
