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

symlink_dotfiles() {
  [ -d ~/.dotfiles ] || ln -sv "${SCRIPT_DIR}/dotfiles" ~/.dotfiles
}

# symlink
symlink_dotfiles
