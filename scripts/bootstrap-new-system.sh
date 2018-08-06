#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo_green () {
  echo -e "${GREEN}$1${NC}"
}

install_oh_my_zsh () {
  # installing zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

  # installing zsh-syntax
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  # Setting zsh as default
  echo_green "Setting zsh as default"
  chsh -s $(which zsh)

  # installing theme
  echo_green "Installing powerline theme"
  sudo apt-get install -y fonts-powerline
}

install_commons () {
  # updating apt-get
  echo_green "Updating apt-get"
  sudo apt-get update && sudo apt-get upgrade

  # install apps
  echo_green "Installing apps"
  sudo apt-get install -y git git-core curl zsh nmap htop iftop \
  vim python-pip python3-pip tmux

  # update pip
  echo_green "Upgrading pip"
  sudo pip install --upgrade pip
  sudo pip3 install --upgrade pip

  # install virtual env
  echo_green "Installing python virtual environment"
  sudo pip install virtualenv && sudo pip3 install virtualenv

  # install nodejs
  echo_green "Installing node.js"
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get install -y nodejs

  # installing http-server
  sudo npm i -g http-server

  # install oh-my-zsh
  install_oh_my_zsh
}

install_desktop () {
  # install desktop apps
  echo_green "Installing Desktop Apps"
  sudo apt-get install -y ubuntu-restricted-extras gimp vlc browser-plugin-vlc \
  libappindicator1 dconf-cli diodon pylint qbittorrent exfat-fuse exfat-utils

  # installing eslint
  sudo npm i -g eslint

  # download chrome
  echo_green "Downloading Chrome"
  wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  # install chrome
  echo_green "Installing Chrome"
  sudo dpkg -i google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb

  # downloading skype
  echo_green "Downloading Skype"
  wget -c https://repo.skype.com/latest/skypeforlinux-64.deb

  # install skype
  echo_green "Installing Skype"
  sudo dpkg -i skypeforlinux-64.deb && rm skypeforlinux-64.deb
}

option="$1"

if [ $# -ne 1 ]; then
  printf "Usage: $0 <server/desktop>"
else
  case "$option" in
    "server") 
      install_commons
      # restore_configs
      ;;
    "desktop")
      install_commons
      install_desktop
      # restore_configs
      ;;
    *)  printf "Invalid argument!\nUsage: $0 <server/desktop>" >&2
        exit 1 ;;
  esac
fi