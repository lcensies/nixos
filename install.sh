#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

symlink() {
  test -d /etc/nixos && \
	 echo "/etc/nixos already exists"  && \
	 return
  # sudo rm -r /etc/nixos/ 2>/dev/null || :
  sudo ln -s   ${SCRIPT_DIR}/nixos/ /etc/nixos
  ln -s   ${SCRIPT_DIR}/home-manager/ ~/.config/home-manager
}

install_home_mgr() {
  which home-manager && return
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
}

symlink_dotfiles() {
  -d ~/.dotfiles && return
  ln -s ${SCRIPT_DIR}/dotfiles ~/.dotfiles
}

symlink
symlink_dotfiles
install_home_mgr

