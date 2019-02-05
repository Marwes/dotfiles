#!/usr/bin/env bash
set -eux

cp -r .config .tmux.conf ~/

git config --global user.name "Markus Westerlind"
EMAIL=$1
git config --global user.email ${EMAIL}

sudo apt-get update
sudo apt-get install curl tmux fish python3-pip pkg-config libssl-dev -y

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x nvim.appimage
sudo mv ./nvim.appimage /usr/local/bin/nvim

if [ ! -f ~/.config/nvim ]; then
    (mkdir -p ~/.config && \
        cd ~/.config/ && \
        git clone https://github.com/Marwes/vim-config nvim)
    nvim -c 'PlugInstall|qa'
fi

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip3 install neovim

git config --global merge.tool vimdiff
git config --global mergetool.prompt true
git config --global mergetool.vimdiff.cmd "nvim -d \$LOCAL \$REMOTE \$MERGED -c '\$wincmd w' -c 'wincmd J'"
git config --global difftool.prompt false
git config --global diff.tool vimdiff

cp .gitignore ~/
git config --global core.excludesfile "$HOME/.gitignore"


# Rust
which rustup || (curl https://sh.rustup.rs -sSf | sh && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt-preview rls-preview &&
    rustup install nightly && \
    rustup component add --toolchain nightly rustfmt-preview rls-preview &&
    cargo install cargo-watch cargo-tree cargo-outdated ripgrep)


# docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce -y
sudo usermod -a -G docker $USER
pip3 install --user docker-compose
