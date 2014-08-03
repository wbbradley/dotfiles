dotfiles
========


```sh
mkdir $HOME/src
cd $HOME/src
mkdir -p $HOME/.config/powerline
pip install --user git+git://github.com/Lokaltog/powerline
mkdir -p $HOME/.vim/autoload ~/.vim/bundle && curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd $HOME/src
git clone https://github.com/wbbradley/dotfiles.git
cd dotfiles
./install.py
vi +BundleInstall
```

