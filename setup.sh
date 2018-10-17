#!/usr/bin/env bash
set -eux

git config --global user.name "Markus Westerlind"
EMAIL=$1
git config --global user.email ${EMAIL}

sudo apt-get update
sudo apt-get install tmux fish python3-pip pkg-config libssl-dev -y

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x nvim.appimage
sudo mv ./nvim.appimage /usr/local/bin/nvim

# docker
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get install docker-ce
pip3 install --user docker-compose


which rustup || (curl https://sh.rustup.rs -sSf | sh && \
    rustup component add rustfmt-preview rls-preview &&
    rustup install nightly && \
    rustup component add --toolchain nightly rustfmt-preview rls-preview &&
    cargo install cargo-watch ripgrep)

cp -r .config .tmux.conf ~/

if [ ! -f ~/.config/nvim]; then
    (cd ~/.config/ && git clone https://github.com/Marwes/vim-config nvim)
fi

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip3 install neovim