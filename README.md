dotfiles
========

My dotfiles

You'll need to install pathogen and vundle. To get everything installed, run `./install.py`

```sh
apt-get install git
mkdir $HOME/src
cd $HOME/src
git clone https://github.com/milkbikis/powerline-shell
cd powerline-shell
./install.py
mkdir -p $HOME/.vim/autoload ~/.vim/bundle && curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd $HOME/src
git clone https://github.com/wbbradley/dotfiles.git
cd dotfiles
./install.py
vi +BundleInstall
```
