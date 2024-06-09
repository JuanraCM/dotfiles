# dotfiles

This repo contains my dotfile configuration that I use across multiple machines. I mainly use it on GNU/Linux (Ubuntu distribution) and MacOS.

## Installation guide (Ubuntu)

1. Clone the repository and cd into it:

```bash
git clone git@github.com:JuanraCM/dotfiles.git && cd dotfiles
```

1. Install the necessary packages and its dependencies:

```bash
sudo apt install zsh git stow tmux wl-clipboard ninja-build gettext cmake unzip curl build-essential ripgrep
```

2. Set up all the symlinks using stow:

```bash
stow .
```

3. Set ZSH as the default shell and logout:

```bash
chsh -s $(which zsh)
gnome-session-quit
```

4. Download and build Neovim from source:

```bash
git clone git@github.com:neovim/neovim.git && cd neovim
git checkout stable

make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

5. Install MesloLGS NF font (remember to update your terminal font after this):

```bash
fc-cache -f -v
```

## Installation guide (MacOS)

1. Clone the repository and cd into it:

```bash
git clone git@github.com:JuanraCM/dotfiles.git && cd dotfiles
```

1. Install the necessary packages and its dependencies:

```bash
brew install stow tmux ninja gettext cmake curl ripgrep
```

2. Set up all the symlinks using stow:

```bash
stow .
```

3. Logout:

```bash
logout
```

4. Download and build Neovim from source:

```bash
git clone git@github.com:neovim/neovim.git && cd neovim
git checkout stable

make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

5. Install MesloLGS NF font (remember to update your terminal font after this):

```bash
cp .local/share/fonts/* ~/Library/Fonts
