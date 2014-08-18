#!/usr/bin/python
from os.path import dirname, join, abspath, exists, expanduser, basename, islink
import os
from sys import platform

user_dir = expanduser('~')
vim_dir = join(user_dir, '.vim')
vim_color_dir = join(vim_dir, 'colors')
vim_indent_dir = join(vim_dir, 'indent')
ftplugin_dir = join(vim_dir, 'ftplugin')
bin_dir = join(user_dir, 'bin')

files = {
    '.bash_profile': {
        'install_dir': user_dir,
        'overwrite': False,
    },
    '.bashrc': {
        'install_dir': user_dir,
    },
    '.tmux.conf': {
        'install_dir': user_dir,
    },
    '.git-completion.sh': {
        'install_dir': user_dir,
    },
    '.vimrc': {
        'install_dir': user_dir,
    },
    '.ctags': {
        'install_dir': user_dir,
    },
    '.inputrc': {
        'install_dir': user_dir,
    },
    'gs': {
        'install_dir': bin_dir,
    },
    'f': {
        'install_dir': bin_dir,
    },
    'py.vim': {
        'install_dir': ftplugin_dir,
    },
    'coffee.vim': {
        'install_dir': ftplugin_dir,
    },
    'ir_black.vim': {
        'install_dir': vim_color_dir,
    },
    # See pdbpp - a very useful python debugger extension
    '.pdbrc.py': {
        'install_dir': user_dir,
    },
}


def get_src_path(file):
    return abspath(join(dirname(__file__), file))


def get_home_dir_path(file):
    return abspath(join(expanduser('~'), file))


def get_dest_path(file_, options):
    install_dir = options['install_dir']
    return abspath(join(install_dir, file_))


def _get_other_files(options):
    if type(options) == tuple:
        return options[0]
    else:
        return options


def _system(cmd):
    # print(basename(__file__) + ' running: ' + cmd)
    os.system(cmd)


def setup_git():
    _system('git config --global user.name "Will Bradley"')
    _system('git config --global color.diff always')
    _system('git config --global --add color.ui true')
    _system('git config --global core.editor "/usr/bin/vim"')
    _system('git config --global push.default tracking')
    _system('git config --global branch.autosetuprebase always')


def setup_system_prefs():
    if platform == 'darwin':
        _system('defaults write -g InitialKeyRepeat -int 15')
        _system('defaults write -g KeyRepeat -int 0')


def setup_vim():
    _system('rm -rf $HOME/.vim')
    _system('rm -rf $HOME/.config/powerline')
    _system('mkdir -p ~/.vim/bundle')
    _system('mkdir -p ~/.vim/autoload')
    _system('git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle')
    _system('curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim')


def _backup(filename):
    if not exists(filename):
        return
    trash_dir = abspath(join(expanduser('~'), '.Trash'))
    if not exists(trash_dir):
        trash_dir = None

    backup_filename = filename + '.bak'
    if trash_dir:
        backup_filename = join(trash_dir, basename(backup_filename))

    _system('mv ' + filename + ' ' + backup_filename)
    print("install.py : info : moved {} to {}".format(filename, backup_filename))


def link_files():
    for file, options in files.iteritems():
        source_file = get_src_path(file)
        dest_file = get_dest_path(file, options)
        dest_file_path = dirname(dest_file)

        if exists(dest_file) and not options.get('overwrite', True):
            print "install.py : info : skipping {}".format(dest_file)
            continue

        if not exists(dest_file_path):
            _system('mkdir -p ' + dest_file_path)

        if exists(file):
            _backup(dest_file)

            for other_file in _get_other_files(options):
                other_dest_file = get_home_dir_path(other_file)
                _backup(other_dest_file)

            print "install.py : info : installing {}".format(source_file)
            _system('ln -sf ' + source_file + ' ' + dest_file)


def setup_powerline():
    if platform == 'darwin':
        print "install.py : info : installing powerline..."
        _system('sudo pip install --upgrade git+git://github.com/Lokaltog/powerline')
    else:
        _system('pip install --user --install-option="--prefix=" --upgrade git+git://github.com/Lokaltog/powerline')


if __name__ == '__main__':
    setup_powerline()
    setup_git()
    setup_system_prefs()
    setup_vim()
    link_files()
    _system('vi +BundleInstall +q +q')
