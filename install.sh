#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

symlink() {
  sudo rm -r /etc/nixos/ 2>/dev/null || :
  sudo ln -s   ${SCRIPT_DIR}/nixos/ /etc/nixos
}

install_home_mgr() {
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
}

symlink
install_home_mgr
