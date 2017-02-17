#!/usr/bin/python

import os
import datetime
from csv import DictReader

datadir = 'rawdata/'
for dirpath, dirnames, files in os.walk(datadir):
    for f in files:
        fic = os.path.join(dirpath, f)
        with open(fic) as csvfile:
            name = f.rsplit('.')[0]
            collection = db[name]
            for row in DictReader(csvfile, delimiter = ';'):
                dateKeys = [k for (k,v) in row if "_D_" in k]
                for k in dateKeys:
                    try:
                        row[k] = datetime.strptime(val, "%d/%b/%Y")
                    except ValueError as e:
                            pass
