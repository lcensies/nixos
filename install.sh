#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
BACKUP_TIMESTAMP=$(date +%Y-%m-%d-%H-%M)

symlink() {
  if [ -d /etc/nixos ]; then
    local backup_dir="/etc/nixos.backup-${BACKUP_TIMESTAMP}"
    echo "/etc/nixos already exists - moving to ${backup_dir}"
    sudo mv -v /etc/nixos "${backup_dir}"
  fi
  sudo ln -sv "${SCRIPT_DIR}/nixos/" /etc/nixos
  mkdir -p ~/.config
  ln -sv "${SCRIPT_DIR}/home-manager/" ~/.config/home-manager
}

install_home_mgr() {
  command -v home-manager >/dev/null && return
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  echo "You may need to install home-manager via nix-shell now"
}

symlink_dotfiles() {
  [ -d ~/.dotfiles ] && return
  ln -sv "${SCRIPT_DIR}/dotfiles" ~/.dotfiles
}

symlink
symlink_dotfiles
install_home_mgr
