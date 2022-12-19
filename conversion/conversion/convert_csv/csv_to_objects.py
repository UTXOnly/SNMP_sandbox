import csv
import objects_to_snmprec as objects_to_snmprec

# Defining empty lists to seperate csv data
mibs = []
oids = []
data_types = []
object_permissions = []
object_classes = []
object_node_types = []
object_descriptions = []
line_count = []
mib_entry_objects = []

class mib_entry:
    def __init__(self, mib, oid, data_type, object_permissions, object_class, object_node_type, object_description):
        self.mib = mib
        self.oid = oid
        self.data_type = data_type
        self.object_permissions = object_permissions
        self.object_class = object_class
        self.object_node_type = object_node_type
        self.object_description = object_description

    def __str__(self) -> str:
        return '{},{},{},{},{},{},{}'.format(self.mib,self.oid,self.data_type,self.object_permissions, self.object_class,self.object_node_type, self.object_description)

    def convert_object(self):
        #print(self)
        if self.object_class == "moduleidentity" :
            if self.object_node_type != "none":
                print("- MIB:", self.mib,"\n  table:")
                print(self.mib, "test1")
            elif self.object_node_type == "table" :
                print(self.object_node_type, "is not none")
                print(self.mib, self.object_node_type)
            #print(self.object_class)
        elif self.object_node_type == "table" and self.object_class == "objecttype":
            print(self.mib, "Is a table") 
            
        elif self.object_node_type == "row":
            print(self.mib, "Is a row")
            
        elif self.object_node_type == "column":
            #print(self.mib, "Is a column")
            print("- column:","\n    OID:", self.oid, "\n    name:", self.mib)

def parse_csv(csv_to_analyize):
    #csv_file = csv_to_analyize 
    with open(csv_to_analyize, mode='r') as csv_file:
        csv_file_opened = csv.reader(csv_file, delimiter=',')

        for row in csv_file_opened:
            line_count.append(1)
            for column in row:
                while column == row[0] and len(mibs) < len(line_count):
                    if column == row[0] and len(column) > 0:
                        mibs.append(column)
                        #print(column)
                    else:
                        mibs.append("none ")
                while column == row[1] and len(oids) < len(line_count):
                    if column == row[1] and len(column) > 0:
                        oids.append(column)
                        #print(column)
                    else:
                        oids.append("none ")
                while column == row[2] and len(data_types) < len(line_count):
                    if column == row[2] and len(column) > 0:
                        data_types.append(column)
                        #print(column)
                    else:
                        data_types.append("none ")
                while column == row[3] and len(object_permissions) < len(line_count):
                    if column == row[3] and len(column) > 0:
                        object_permissions.append(column)
                        #print(column)
                    else:
                        object_permissions.append("none ")
                while column == row[4] and len(object_classes) < len(line_count):
                    if column == row[4] and len(column) > 0:
                        object_classes.append(column)
                        #print(column)
                    else:
                        object_classes.append("none ")
                while column == row[5] and len(object_node_types) < len(line_count):
                    if column == row[5] and len(column) > 0:
                        object_node_types.append(column)
                        #print(column)
                    else:
                        object_node_types.append("none ")
                while column == row[6] and len(object_descriptions) < len(line_count):
                    if column == row[6] and len(column) > 0:
                        object_descriptions.append(column)
                        #print(column)
                    else:
                        object_descriptions.append("none ")

# Function to iterate through lists produced from csv and create objects from each row
def extract_list(list_to_extract):
    i = 0
    while i < (len(list_to_extract)):
        obj = mib_entry(mibs[i], oids[i], data_types[i], object_permissions[i], object_classes[i], object_node_types[i], object_descriptions[i])
        mib_entry_objects.append(obj)
        #print(obj)   
        i += 1
        obj.convert_object()

# Calling functons to parse csv and turn entrys into objects of the class mib_entry
parse_csv('./csv+snmprec/file_to_analyize.csv')
extract_list(line_count)
objects_to_snmprec.create_snmp_rec(mib_entry_objects)
print("Checking lengths of csv column lists \n")
print( len(mibs), len(oids), len(data_types), len(object_permissions), len(object_classes), len(object_node_types), len(object_descriptions))
print ("\nAll values in this row should be equal, otheriwise parsing csv has failed")