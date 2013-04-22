#!/usr/local/bin/python
from os.path import dirname, join, abspath, exists, expanduser, basename
import os

files = [
    ('.bash_profile', ['.bashrc']),
    ('.vimrc', []),
    ('.inputrc', []),

    # See pdbpp - a very useful python debugger extension
    ('.pdbrc.py', []),
]


def get_dest_path(file):
    return abspath(join(expanduser('~'), file))


def system(cmd):
    # print(basename(__file__) + ' running: ' + cmd)
    os.system(cmd)

if not exists(abspath(join(expanduser('~'), '.vim', 'autoload', 'pathogen.vim'))):
    system('mkdir -p ~/.vim/autoload ~/.vim/bundle')
    system('curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim')

def backup(filename):
    if not exists(filename):
        return
    trash_dir = abspath(join(expanduser('~'), '.Trash'))
    if not exists(trash_dir):
        trash_dir = None

    backup_filename = filename + '.bak'
    if trash_dir:
        backup_filename = join(trash_dir, basename(backup_filename))

    system('mv ' + filename + ' ' + backup_filename)
    print("install.py : info : moved {} to {}".format(filename, backup_filename))

for file_tuple in files:
    file = file_tuple[0]
    source_file = abspath(join(dirname(__file__), file))
    dest_file = get_dest_path(file)
    if exists(file):
        backup(dest_file)

        for other_file in file_tuple[1]:
            other_dest_file = get_dest_path(other_file)
            backup(other_dest_file)

        print("install.py : info : installing {}".format(source_file))
        system('ln -sf ' + source_file + ' ' + dest_file)
