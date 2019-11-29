#!/usr/bin/env bash
set -eux

cp -r .config .tmux.conf ~/

git config --global user.name "Markus Westerlind"
EMAIL=$1
git config --global user.email ${EMAIL}


if [ "$(uname -s)" == "Darwin" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install fish tmux python3
else
    sudo apt-get update
    sudo apt-get install curl fish tmux python3-pip pkg-config libssl-dev -y
fi

install_nvim() {
    if [ "$(uname -s)" == "Darwin" ]; then
        brew install neovim
    else
        curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
        chmod u+x nvim.appimage
        sudo mv ./nvim.appimage /usr/local/bin/nvim
    fi

    if [ ! -d ~/.config/nvim ]; then
        (mkdir -p ~/.config && \
            cd ~/.config/ && \
            git clone https://github.com/Marwes/vim-config nvim)

        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        nvim -c 'PlugInstall|qa'
    fi

    pip3 install neovim
}

install_nvim &

git config --global merge.tool vimdiff
git config --global mergetool.prompt true
git config --global mergetool.vimdiff.cmd "nvim -d \$LOCAL \$REMOTE \$MERGED -c '\$wincmd w' -c 'wincmd J'"
git config --global difftool.prompt false
git config --global diff.tool vimdiff

cp .gitignore ~/
git config --global core.excludesfile "$HOME/.gitignore"


install_rust() {
    (curl https://sh.rustup.rs -sSf | sh && \
        . $HOME/.cargo/env && \
        rustup component add rustfmt-preview rls-preview &&
        rustup install nightly && \
        rustup component add --toolchain nightly rustfmt-preview rls-preview &&
        cargo install cargo-watch cargo-tree cargo-outdated ripgrep)
}

which rustup || install_rust &

install_docker() {
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
}

install_docker &

wait
