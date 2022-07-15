#!/bin/bash

# Installs all the necessary applications and links configs to their correct locations

clr_rst="\e[00m"
clr_red="\e[31m"
clr_green="\e[32m"
clr_orange="\e[33m"
clr_blue="\e[34m"
clr_purple="\e[35m"

# Applications to install
dependancies=(
    neovim
    tmux
    xterm
    lynx
)

os_type=$(head -n3 /etc/os-release | awk -F= '/ID=/ {print $NF}')
if [ "$os_type" == "arch" ]
then
    package_manager="pacman"
    update="$package_manager -Syu --noconfirm"
    install="$package_manager -S --noconfirm"
elif [ "$os_type" == "fedora" ]
then
    package_manager="yum"
    update="$package_manager update -y"
    install="$package_manager install -y"
elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
then
    package_manager="apt-get"
    update="$package_manager update -y"
    install="$package_manager install -y"
else
    echo -e "${clr_red}OS not supported"
    exit 1
fi


log_file=/dev/null

if [ "$1" == "verbose" ]
then
    log_file=/dev/stdout
fi

echo -e "${clr_purple}Beginning System Setup${clr_rst}"
echo -e "${clr_blue}... Running on $os_type${clr_rst}"
echo -e "${clr_blue}... Using $package_manager${clr_rst}"
echo -e "${clr_blue}... Writting output to log file: $log_file${clr_rst}"

function dep_install() {
    echo -e "${clr_green}Installing ${dependancies[*]}${clr_rst}"
    sudo $update &> $log_file
    sudo $install ${dependancies[*]} &> $log_file
}

function dotfile_setup() {
    # Dotfiles
    echo -e "${clr_green}Setting up dotfiles${clr_rst}"
    for file in ./dotfiles/*
    do
        #strip path off file
        filename=$(ls $file | awk -F/ '{print $NF}')

        link_path=$PWD/dotfiles/$filename
        link_name=$HOME/.$filename

        echo -e "${clr_blue}... Linking $link_path to $link_name${clr_orange}"
        ln -sf $link_path $link_name
    done
}

function config_dir_setup() {
    # Config directories
    echo -e "${clr_green}Setting up config dirs${clr_rst}"
    mkdir -p $HOME/.config
    for dir in $(ls ./conf.d)
    do
        link_path=$PWD/$dir
        link_name=$HOME/.config/$dir

        echo -e "${clr_blue}... Linking $link_path to $link_name${clr_orange}"
        ln -sf $link_path $link_name
    done
}

function nvim_setup() {
    # Nvim Setup
    echo -e "${clr_green}Setting up NeoVim${clr_rst}"
    nvim --headless -c PackerInstall &> $log_file &
    pid=$(ps aux | awk '/nvim/ {print $0}')

    echo -e "${clr_blue}... Waiting 10s for plugins to install${clr_rst}"
    sleep 10
    sudo pkill nvim
}

if [ "$1" == "help" ]
then
    echo "Run this scipt to install:"
    echo "${dependancies[*]}"
    echo ""
    echo "Usage:"
    echo "    Basic Install:"
    echo "$ ./install.sh"
    echo ""
    echo "    Verbose Install:"
    echo "$ ./install.sh verbose"
    echo ""
    echo "    Help:"
    echo "$ ./install.sh help"
else
    dep_install && \
    dotfile_setup && \
    config_dir_setup && \
    nvim_setup

    if [ $? -eq 0 ]
    then
        echo -e "${clr_green}Success!${clr_rst}"
    else
        echo -e "${clr_red}Failed!${clr_rst}"
    fi
fi
