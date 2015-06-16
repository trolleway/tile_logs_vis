#!/usr/bin/env python
"""

"""
import csv
import sys
import os
from decimal import *
DELIMITER = os.getenv('DELIMITER', ' ')



if __name__ == '__main__':
    reader = csv.reader(sys.stdin, delimiter=DELIMITER)
    writer = csv.writer(sys.stdout, delimiter=',')

    for row in reader:
        date = str(row[0])
        z = int(row[1])
        x = int(row[2])	
        y = int(row[3])
        wkt = str(row[4])
        v = int(row[5])
        lat = Decimal(row[6])
        lng = Decimal(row[7])
        writer.writerow(row)
