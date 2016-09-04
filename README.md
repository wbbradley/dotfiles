dotfiles
========

# Pre-installation steps

```sh
# Clone the repo somewhere. I use ~/src for all my Github repos.

export INSTALL_DIR=$HOME/src
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR
git clone https://github.com/wbbradley/dotfiles.git
cd $INSTALL_DIR/dotfiles
git submodule init
git submodule update

# Install the GNU Stow tool
brew install stow
```

# Installing vim files

```sh
cd $INSTALL_DIR/dotfiles
stow -t $HOME vim
vim +BundleInstall +qa
```

# Installing bash files

My bash setup requires special steps.

```sh
mkdir $HOME/.bash
cd $HOME/.bash
git clone git://github.com/jimeh/git-aware-prompt.git

cd $INSTALL_DIR/dotfiles
stow -t $HOME bash
```
