#!/usr/bin/env python
import os
import sys
from os.path import join

sys_args = [arg.lower() for arg in sys.argv[1:]]

def args_filter(item):
    item = item.lower()
    for arg in sys_args:
        if item.find(arg) == -1:
            return False
    return True

for path, subdirs, files in os.walk('.'):
    for name in filter(args_filter, (join(path, name) for name in files)):
        name = name[2:]
        print name
