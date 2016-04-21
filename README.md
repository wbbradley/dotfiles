dotfiles
========

# Pre-installation steps

```sh
# Clone the repo somewhere
mkdir $HOME/src
cd $HOME/src
git clone https://github.com/wbbradley/dotfiles.git
git submodule init
git submodule update

# Install the GNU Stow tool
brew install stow
```

# Installing vim files

```sh
cd $HOME/src/dotfiles
stow -t $HOME vim
```

# Installing bash files

My bash setup requires special steps.

```sh
mkdir ~/.bash
cd ~/.bash
git clone git://github.com/jimeh/git-aware-prompt.git

cd $HOME/src/dotfiles
stow -t $HOME bash
```
