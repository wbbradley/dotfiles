#!/usr/local/bin/python
from os.path import dirname, join, abspath, exists, expanduser, basename
import os

ftplugin_dir = join(expanduser('~'), '.vim', 'ftplugin')

files = {
    '.bash_profile': ['.bashrc'],
    '.vimrc': [],
    '.ctags': [],
    '.inputrc': [],
    'py.vim': ([], ftplugin_dir),
    'coffee.vim': ([], ftplugin_dir),
    # See pdbpp - a very useful python debugger extension
    '.pdbrc.py': [],
}

def get_src_path(file):
    return abspath(join(dirname(__file__), file))

def get_home_dir_path(file):
    return abspath(join(expanduser('~'), file))

def get_dest_path(file, options):
    if type(options) == tuple:
        if len(options) > 1:
            return abspath(join(options[1], file))
    return get_home_dir_path(file)

def get_other_files(options):
    if type(options) == tuple:
        return options[0]
    else:
        return options

def system(cmd):
    # print(basename(__file__) + ' running: ' + cmd)
    os.system(cmd)

system('git config --global color.diff always')
system('git config --global --add color.ui true')
system('git config --global core.editor "/usr/bin/vim"')
system('git config --global push.default tracking')

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

for file, options in files.iteritems():
    source_file = get_src_path(file)
    dest_file = get_dest_path(file, options)
    dest_file_path = dirname(dest_file)
    system('mkdir -p ' + dest_file_path)
    if exists(file):
        backup(dest_file)

        for other_file in get_other_files(options):
            other_dest_file = get_home_dir_path(other_file)
            backup(other_dest_file)

        print("install.py : info : installing {}".format(source_file))
        system('ln -sf ' + source_file + ' ' + dest_file)
