#!/bin/bash

USER=`whoami`
OS=`grep "^NAME=" /etc/os-release | cut -d\" -f2 | cut -d' ' -f1`

if_package() {
    test $OS = "Arch" && package="pacman -S"
    test $OS = "Debian" && package="apt install -y"
    test $OS = "Centos" && package="yum instll -y"
}

zsh_install() {
    
    /bin/bash ./zinit.sh
    cp ./.zshrc ~/
}

package_install() {

    $package ranger nvim tmux 
    echo "▓▒░ Plugin to install ..."
}

configuration() {
    # start proxy
    proxy

    # zinit install
    /bin/bash ./zinit.sh
    cp ./.zshrc ~/

    # vim-plug install 
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
               https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    # vim configuration 
    test ! -d ~/nvim && mkdir -p ~/nvim
    cp ./init.vim ~/nvim 

    # tmux configuration
    cp ./.tmux.conf ~
}


#zsh_install
if_package
configuration
