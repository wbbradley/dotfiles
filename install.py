#!/usr/bin/python
from os.path import dirname, join, abspath, exists, expanduser, basename
import os
import sys
from sys import platform

user_dir = expanduser('~')
vim_dir = join(user_dir, '.vim')
vim_color_dir = join(vim_dir, 'colors')
vim_syntax_dir = join(vim_dir, 'syntax')
vim_indent_dir = join(vim_dir, 'indent')
vim_ftplugin_dir = join(vim_dir, 'ftplugin')
bin_dir = join(user_dir, 'bin')

files = {
    '.bash_profile': {
        'install_dir': user_dir,
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
    'master': {
        'install_dir': bin_dir,
    },
    'py.vim': {
        'install_dir': vim_ftplugin_dir,
    },
    'coffee.vim': {
        'install_dir': vim_ftplugin_dir,
    },
    'vim/colors/ir_black.vim': {
        'install_dir': vim_color_dir,
    },
    'vim/syntax/cider.vim': {
        'install_dir': vim_syntax_dir,
    },
    'vim/indent/cider.vim': {
        'install_dir': vim_indent_dir,
    },
    'vim/ftplugin/cider.vim': {
        'install_dir': vim_ftplugin_dir,
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
    return abspath(join(install_dir, basename(file_)))


def _get_other_files(options):
    if type(options) == tuple:
        return options[0]
    else:
        return options


def _system(cmd, cwd=None):
    if cwd:
        from subprocess import Popen
        Popen(cmd, shell=True, cwd=cwd)
    else:
        os.system(cmd)


def setup_git():
    _system('git config --global color.diff always')
    _system('git config --global --add color.ui true')
    _system('git config --global core.editor "/usr/bin/vim"')
    _system('git config --global push.default tracking')
    _system('git config --global branch.autosetuprebase always')


def setup_system_prefs():
    if platform == 'darwin':
        _system('defaults write -g InitialKeyRepeat -int 15')
        _system('defaults write -g KeyRepeat -int 0')
        _system('defaults write com.apple.finder AppleShowAllFiles true')


def setup_vim():
    _system('rm -rf $HOME/.vim')
    _system('mkdir -p ' + vim_color_dir)
    _system('mkdir -p ' + vim_syntax_dir)
    _system('mkdir -p ' + vim_indent_dir)
    _system('mkdir -p ' + vim_ftplugin_dir)
    _system('mkdir -p ~/.vim/bundle')
    _system('mkdir -p ~/.vim/autoload')
    _system('git clone https://github.com/gmarik/vundle.git '
            '~/.vim/bundle/vundle')
    _system('curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim')  # noqa


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
    print (
        "install.py : info : moved {} to {}"
        .format(filename, backup_filename)
    )


def link_files():
    for file, options in files.iteritems():
        source_file = get_src_path(file)
        dest_file = get_dest_path(file, options)
        dest_file_path = dirname(dest_file)

        print source_file
        print dest_file
        print dest_file_path

        if exists(dest_file):
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


def setup_vim_bundles():
    _system('vim +BundleInstall +qa')


def setup_ctags():
    if platform == 'darwin':
        _system('brew install ctags-exuberant')
    else:
        _system('sudo apt-get install exuberant-ctags')


def setup_the_silver_searcher():
    if platform == 'darwin':
        _system('brew install the_silver_searcher')
    else:
        _system('sudo apt-get install -y automake pkg-config libpcre3-dev '
                'zlib1g-dev liblzma-dev')
        _system('mkdir -p ~/src')
        _system('rm -rf ~/src/the_silver_searcher')
        _system('git clone https://github.com/ggreer/the_silver_searcher.git', cwd=get_home_dir_path('src'))
        _system('./build.sh', cwd=get_home_dir_path('src/the_silver_searcher'))
        _system('sudo make install', cwd=get_home_dir_path('src/the_silver_searcher'))


def setup_fak():
    _system('mkdir -p ~/src')
    _system('rm -rf ~/src/fak')
    _system('git clone https://github.com/wbbradley/fak.git', cwd=get_home_dir_path('src'))
    fak_dir = get_home_dir_path('src/fak')
    _system('make -C {}'.format(fak_dir))
    _system('ln -sf {} {}'.format(join(fak_dir, 'fak'), bin_dir))


def setup_reattach_to_user_namespace():
    if platform == 'darwin':
        _system('brew install reattach-to-user-namespace')


def setup_go():
    _system('mkdir $HOME/go')
    if platform == 'darwin':
        _system('brew install go')


def setup_git_aware_prompt():
    _system('rm -rf ~/.bash')
    _system('mkdir -p ~/.bash')
    _system('git clone git://github.com/jimeh/git-aware-prompt.git', cwd=get_home_dir_path('.bash'))


def clean_tmp_junk():
    if platform == 'darwin':
        tmp_dir = os.environ.get('TMPDIR')
        if len(tmp_dir) > 10 and tmp_dir.find('..') == -1:
            # sanity check before running this STRONG command
            _system('rm -rf {}/*'.format(tmp_dir))


if __name__ == '__main__':
    steps = [
        clean_tmp_junk,
        setup_git_aware_prompt,
        setup_git,
        setup_system_prefs,
        setup_vim,
        link_files,
        setup_vim_bundles,
        setup_ctags,
        setup_the_silver_searcher,
        setup_fak,
        setup_reattach_to_user_namespace,
        setup_go,
    ]

    for step in steps:
        print 'install.py : info : running {}'.format(step.__name__)
        step()
