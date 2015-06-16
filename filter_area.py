#!/usr/bin/env python
"""
Filter out all points in Switzerland
"""
import csv
import sys
import os
import argparse
from decimal import *


DELIMITER = os.getenv('DELIMITER', ' ')
NORTH = Decimal('89.930459')
WEST = Decimal('19.1')
EAST = Decimal('179.9')
SOUTH = Decimal('0.1')


def in_switzerland(coords):
    lat, lng = coords
    return lat < NORTH and lat > SOUTH and lng > WEST and lng < EAST


if __name__ == '__main__':
    reader = csv.reader(sys.stdin, delimiter=DELIMITER)
    writer = csv.writer(sys.stdout, delimiter=DELIMITER)

    for row in reader:
        z = int(row[0])
        x = int(row[1])	
        y = int(row[2])
        wkt = str(row[3])
        v = int(row[4])
        lat = Decimal(row[5])
        lng = Decimal(row[6])
        

        if in_switzerland((lat, lng)):
            writer.writerow([z, x, y, wkt, v, lat, lng])
