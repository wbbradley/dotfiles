dotfiles
========

My dotfiles

You'll need to install pathogen and vundle. To get everything installed, run `./install.py`

```sh
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
mkdir ~/src
cd ~/src
git clone https://github.com/wbbradley/dotfiles.git
cd dotfiles
./install.py
vi +BundleInstall
```
