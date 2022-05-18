#!/usr/bin/env bash
set -eux

cp -r .config .tmux.conf ~/

git config --global user.name "Markus Westerlind"
EMAIL=$1
git config --global user.email ${EMAIL}

if [ ! -f ~/.ssh/id_rsa ]; then
    (cd ~/.ssh/ && ssh-keygen -t rsa -b 4096 -C ${EMAIL})
fi


if [ "$(uname -s)" == "Darwin" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install fish tmux python3
else
    sudo apt-get update
    sudo apt-get install curl cmake fish tmux python3-pip pkg-config libssl-dev linux-tools-common xclip -y
    sudo apt-get install libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev -y # For alacritty
fi

install_nvim() {
    if [ "$(uname -s)" == "Darwin" ]; then
        brew install neovim
    else
        NVIM_VERSION=v0.7.0
        curl -LO https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz
        tar xvf nvim-linux64.tar.gz
        chmod +x nvim-linux64/bin/nvim
        sudo cp -r nvim-linux64/* /usr/local/
        rm -r nvim-linux64 nvim-linux64.tar.gz
    fi

    if [ ! -d ~/.config/nvim ]; then
        (mkdir -p ~/.config && \
            cd ~/.config/ && \
            git clone git@github.com:Marwes/vim-config nvim)

        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        nvim -c 'PlugInstall|qa'
    fi

    pip3 install neovim
}

which rustup || install_nvim

configurate_git() {
    git config --global merge.tool vimdiff
    git config --global mergetool.prompt true
    git config --global mergetool.vimdiff.cmd "nvim -d \$LOCAL \$REMOTE \$MERGED -c '\$wincmd w' -c 'wincmd J'"
    git config --global difftool.prompt false
    git config --global diff.tool vimdiff

    cp .gitignore ~/
    git config --global core.excludesfile "$HOME/.gitignore"
}

configurate_git &

install_rust() {
    (curl https://sh.rustup.rs -sSf > rustup.sh && sh rustup.sh -y && rm rustup.sh && \
        . $HOME/.cargo/env && \
        rustup component add rustfmt-preview &&
        rustup install nightly && \
        rustup component add --toolchain nightly rustfmt-preview rust-analysis &&
        cargo install cargo-watch cargo-tree cargo-outdated ripgrep alacritty fd-find)
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

install_go() {
    GO_VERSION=1.18.2
    curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

    go install golang.org/x/tools/gopls@latest
}

install_go &

wait
