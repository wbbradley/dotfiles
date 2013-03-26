#!/usr/local/bin/python
from os.path import dirname, join, abspath, exists, expanduser, basename
import os

files = [
    ('.bash_profile', ['.bashrc']),
    ('.vimrc', []),
    ('.inputrc', []),
]


def get_dest_path(file):
    return abspath(join(expanduser('~'), file))


def system(cmd):
    print(basename(__file__) + ' running: ' + cmd)
    #os.system(cmd)


for file_tuple in files:
    file = file_tuple[0]
    source_file = abspath(join(dirname(__file__), file))
    dest_file = get_dest_path(file)
    if exists(file):
        if exists(dest_file):
            system('mv ' + dest_file + ' ' + dest_file + '.bak')
        for other_file in file_tuple[1]:
            other_dest_file = get_dest_path(other_file)
            if exists(other_dest_file):
                system('mv ' + other_dest_file + ' '
                       + other_dest_file + '.bak')

        system('ln -sf ' + source_file + ' ' + dest_file)
