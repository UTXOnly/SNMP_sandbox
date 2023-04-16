#!/usr/bin/env python3

from pysnmp.carrier.asyncore.dispatch import AsyncoreDispatcher
from pysnmp.carrier.asyncore.dgram import udp, udp6
from pysnmp.proto.api import v2c
from pysnmp.entity.rfc3413 import cmdgen
import sys


def send_notification(varBinds):
    global sink
    sink = []
    for oid, val in varBinds:
        if isinstance(val, v2c.Null):
            val = None
        else:
            val = v2c.ObjectType(v2c.ObjectIdentity(oid), val).asOctets()
        sink.append((oid, val))


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} SNMPWALK_OUTPUT_FILE", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        lines = [line.strip() for line in f.readlines()]

    cmdGen = cmdgen.CommandGenerator()
    for line in lines:
        oid, val = line.split(' = ')
        oid, val = tuple(oid.split('.')), v2c.OctetString(val.strip('"').encode())

        send_notification([(oid, val)])

    # Write snmprec output to stdout
    for oid, val in sink:
        print(f"{oid} : {val.hex()}")


if __name__ == '__main__':
    main()
